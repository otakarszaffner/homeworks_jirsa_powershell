<#
.SYNOPSIS
    Vytvori aliasy np a ct, ulozi jejich zalohu do JSON a XML,
    smaze je a postupne obnovi z obou souboru.
.NOTES
    Pro zachovani aliasu v aktualni relaci pouzijte dot-sourcing:
    . .\aliasy_zaloha_obnova.ps1

    Zalohy jsou ulozeny vedle skriptu. Nevyzaduje prava spravce.
#>

$pozadovaneAliasy = @(
    [PSCustomObject]@{ Name = 'np'; Definition = 'notepad.exe' }
    [PSCustomObject]@{ Name = 'ct'; Definition = 'control.exe' }
)

$jsonSoubor = Join-Path -Path $PSScriptRoot -ChildPath 'aliasy.json'
$xmlSoubor  = Join-Path -Path $PSScriptRoot -ChildPath 'aliasy.xml'
$krok = 'zacatek'

function Test-Aliasy {
    param([object[]]$Ocekavane)

    foreach ($polozka in $Ocekavane) {
        $alias = Get-Alias -Name $polozka.Name -ErrorAction SilentlyContinue
        if ($null -eq $alias -or $alias.Definition -cne $polozka.Definition) {
            throw "Alias '$($polozka.Name)' neexistuje nebo neukazuje na '$($polozka.Definition)'."
        }
    }
}

function Test-SmazaneAliasy {
    param([object[]]$Ocekavane)

    foreach ($polozka in $Ocekavane) {
        if ($null -ne (Get-Alias -Name $polozka.Name -ErrorAction SilentlyContinue)) {
            throw "Alias '$($polozka.Name)' nebyl odstranen."
        }
    }
}

function Test-Zaloha {
    param(
        [System.Collections.Generic.List[object]]$Zaznamy,
        [object[]]$Ocekavane,
        [string]$Format
    )

    if ($Zaznamy.Count -ne $Ocekavane.Count) {
        throw "Zaloha $Format ma $($Zaznamy.Count) zaznamu, ocekavany pocet je $($Ocekavane.Count)."
    }

    foreach ($polozka in $Ocekavane) {
        $pocetShod = 0
        foreach ($zaznam in $Zaznamy) {
            if ($null -ne $zaznam -and
                $zaznam.Name -ceq $polozka.Name -and
                $zaznam.Definition -ceq $polozka.Definition) {
                $pocetShod++
            }
        }
        if ($pocetShod -ne 1) {
            throw "Zaloha $Format neobsahuje spravny alias '$($polozka.Name)' prave jednou."
        }
    }
}

try {
    $krok = '1/7 - vytvoreni aliasu'
    Write-Host "$krok" -ForegroundColor Cyan
    foreach ($polozka in $pozadovaneAliasy) {
        Set-Alias -Name $polozka.Name -Value $polozka.Definition -Force -ErrorAction Stop
    }
    Test-Aliasy -Ocekavane $pozadovaneAliasy

    # Nacteme skutecne vytvorene aliasy.
    $zaloha = @(
        foreach ($polozka in $pozadovaneAliasy) {
            $alias = Get-Alias -Name $polozka.Name -ErrorAction Stop
            [PSCustomObject]@{
                Name       = $alias.Name
                Definition = $alias.Definition
            }
        }
    )

    $krok = '2/7 - zaloha do JSON a XML'
    Write-Host "$krok" -ForegroundColor Cyan

    # Kazdy zaznam posilame do pipeline zvlast, ne pole jako jeden objekt.
    $zaloha | ConvertTo-Json -Depth 3 -ErrorAction Stop |
        Set-Content -LiteralPath $jsonSoubor -Encoding UTF8 -ErrorAction Stop

    $zaloha | Export-Clixml -LiteralPath $xmlSoubor -ErrorAction Stop

    $krok = '3/7 - prvni smazani aliasu'
    Write-Host "$krok" -ForegroundColor Cyan
    foreach ($polozka in $pozadovaneAliasy) {
        Remove-Item -LiteralPath "Alias:$($polozka.Name)" -Force -ErrorAction Stop
    }
    Test-SmazaneAliasy -Ocekavane $pozadovaneAliasy

    $krok = '4/7 - obnova z JSON'
    Write-Host "$krok" -ForegroundColor Cyan

    # V PS 5.1 muze ConvertFrom-Json predat cele pole jako jediny
    # objekt pipeline. Proto NEPOUZIVAME @( ... | ConvertFrom-Json ).
    # Ziskane polozky explicitne prevedeme na seznam jednotlivych zaznamu.
    $jsonText = Get-Content -LiteralPath $jsonSoubor -Raw -Encoding UTF8 -ErrorAction Stop
    $nactenyJson = ConvertFrom-Json -InputObject $jsonText -ErrorAction Stop
    $zJson = New-Object 'System.Collections.Generic.List[object]'
    foreach ($polozka in $nactenyJson) {
        [void]$zJson.Add($polozka)
    }

    Test-Zaloha -Zaznamy $zJson -Ocekavane $pozadovaneAliasy -Format 'JSON'
    foreach ($polozka in $zJson) {
        Set-Alias -Name $polozka.Name -Value $polozka.Definition -Force -ErrorAction Stop
    }
    Test-Aliasy -Ocekavane $pozadovaneAliasy

    $krok = '5/7 - druhe smazani aliasu'
    Write-Host "$krok" -ForegroundColor Cyan
    foreach ($polozka in $pozadovaneAliasy) {
        Remove-Item -LiteralPath "Alias:$($polozka.Name)" -Force -ErrorAction Stop
    }
    Test-SmazaneAliasy -Ocekavane $pozadovaneAliasy

    $krok = '6/7 - obnova z XML'
    Write-Host "$krok" -ForegroundColor Cyan

    # Stejne jako u JSON sestavime seznam jednotlivych objektu.
    $nacteneXml = Import-Clixml -LiteralPath $xmlSoubor -ErrorAction Stop
    $zXml = New-Object 'System.Collections.Generic.List[object]'
    foreach ($polozka in $nacteneXml) {
        [void]$zXml.Add($polozka)
    }

    Test-Zaloha -Zaznamy $zXml -Ocekavane $pozadovaneAliasy -Format 'XML'
    foreach ($polozka in $zXml) {
        Set-Alias -Name $polozka.Name -Value $polozka.Definition -Force -ErrorAction Stop
    }
    Test-Aliasy -Ocekavane $pozadovaneAliasy

    $krok = '7/7 - zaverecna kontrola'
    Write-Host "$krok" -ForegroundColor Cyan
    Get-Alias -Name np, ct | Format-Table Name, Definition -AutoSize
    Write-Host 'Hotovo: oba aliasy byly uspesne obnoveny z XML.' -ForegroundColor Green
    Write-Host "JSON zaloha: $jsonSoubor"
    Write-Host "XML zaloha:  $xmlSoubor"
}
catch {
    Write-Error "Zpracovani se nezdarilo v kroku '$krok': $($_.Exception.Message)"
}
