<#
.SYNOPSIS
    Ověří, zda je zadaný text palindrom.
.DESCRIPTION
    Ignoruje velikost písmen, diakritiku, mezery a interpunkci.
    Číslice ponechává a porovnává.
.EXAMPLE
    .\palindrom.ps1 -Text 'Kobyla má malý bok'
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [AllowEmptyString()]
    [string] $Text
)

# Bez parametru se text načte interaktivně.
if (-not $PSBoundParameters.ContainsKey('Text')) {
    $Text = Read-Host 'Zadejte text pro kontrolu palindromu'
}

if ([string]::IsNullOrWhiteSpace($Text)) {
    throw 'Chyba: Zadejte neprázdný text.'
}

# Rozloží znaky s diakritikou (např. á -> a + čárka) a odstraní diakritická znaménka.
$bezDiakritiky = $Text.Normalize([System.Text.NormalizationForm]::FormD)
$bezDiakritiky = [regex]::Replace($bezDiakritiky, '\p{Mn}', '')

# Necháme jen písmena a číslice, převedeme na malá písmena.
$ocistenyText = [regex]::Replace($bezDiakritiky, '[^\p{L}\p{Nd}]', '').ToLowerInvariant()

if ($ocistenyText.Length -eq 0) {
    throw 'Chyba: Text neobsahuje žádná písmena ani číslice.'
}

# Obrátíme pořadí znaků a oba řetězce porovnáme.
[char[]] $obraceneZnaky = $ocistenyText.ToCharArray()
[array]::Reverse($obraceneZnaky)
$obracenyText = -join $obraceneZnaky

Write-Output "Zadaný text: $Text"
if ($ocistenyText -ceq $obracenyText) {
    Write-Output 'Výsledek: ANO - text je palindrom.'
} else {
    Write-Output 'Výsledek: NE - text není palindrom.'
}
