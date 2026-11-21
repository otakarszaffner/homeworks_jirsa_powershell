<#
.SYNOPSIS
    Spočítá znaky (s mezerami a bez mezer), samohlásky a slova.
.DESCRIPTION
    Za samohlásky považuje a, e, i, o, u, y a české dlouhé varianty
    á, é, í, ó, ú, ů, ý (bez ohledu na velikost písmen).
    Písmeno w mezi samohlásky nepatří.
.EXAMPLE
    .\analyza-textu.ps1 -Text 'Ahoj světe!'
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [AllowEmptyString()]
    [string] $Text
)

# Pokud není předán parametr, text načteme z terminálu.
if (-not $PSBoundParameters.ContainsKey('Text')) {
    $Text = Read-Host 'Zadejte text k analýze'
}

if ([string]::IsNullOrWhiteSpace($Text)) {
    throw 'Chyba: Zadejte neprázdný text.'
}

# .Length zahrnuje běžné mezery i interpunkci.
$pocetZnakuSMezerami = $Text.Length

# \s odstraní mezery, tabulátory i konce řádků.
$pocetZnakuBezMezer = ([regex]::Replace($Text, '\s', '')).Length

# České samohlásky včetně dlouhých variant; w je souhláska.
$samohlasky = '[aeiouyáéíóúůý]'
$pocetSamohlasek = [regex]::Matches(
    $Text,
    $samohlasky,
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
).Count

# Slovem se zde rozumí každá nepřerušená skupina znaků oddělená bílým znakem.
$pocetSlov = [regex]::Matches($Text, '\S+').Count

Write-Output "Počet znaků s mezerami: $pocetZnakuSMezerami"
Write-Output "Počet znaků bez mezer: $pocetZnakuBezMezer"
Write-Output "Počet samohlásek:      $pocetSamohlasek"
Write-Output "Počet slov:            $pocetSlov"
