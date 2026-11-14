$path = "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard"
$name = "InitialKeyboardIndicators"

try {
    # Nacteni soucasne hodnoty
    $rawValue = (Get-ItemProperty -LiteralPath $path `
        -Name $name -ErrorAction SilentlyContinue).$name

    $value = [long]0

    if ($null -ne $rawValue) {
        if (-not [long]::TryParse(
            [string]$rawValue, [ref]$value
        )) {
            throw "Neplatna hodnota InitialKeyboardIndicators"
        }
    }

    Write-Host "Aktualni hodnota: $value"

    # Bit 2 urcuje pozadovane zapnuti NumLock
    if (($value -band 2) -ne 0) {
        Write-Host "NumLock je nastaven jako zapnuty."
    }
    else {
        # Zapnuti NumLock pri zachovani ostatnich bitu
        $newValue = ($value -bor 2).ToString()

        New-ItemProperty -LiteralPath $path `
            -Name $name `
            -Value $newValue `
            -PropertyType String `
            -Force -ErrorAction Stop | Out-Null

        Write-Host "NumLock byl nastaven na zapnuto."
        Write-Host "Nova hodnota: $newValue"
    }
}
catch {
    Write-Error "Nepodarilo se upravit NumLock: $_"
}
