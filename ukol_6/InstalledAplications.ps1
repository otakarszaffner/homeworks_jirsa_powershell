$software = @()

# 1. ZDROJ - REGISTRY WINDOWS

$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $registryPaths) {

    $programs = Get-ItemProperty -Path $path `
        -ErrorAction SilentlyContinue

    foreach ($program in $programs) {

        if ([string]::IsNullOrWhiteSpace($program.DisplayName)) {
            continue
        }

        $software += [PSCustomObject]@{
            Name            = $program.DisplayName
            Version         = $program.DisplayVersion
            Publisher       = $program.Publisher
            InstallDate     = $program.InstallDate
            InstallLocation = $program.InstallLocation
            UninstallString = $program.UninstallString
            SizeKB          = $program.EstimatedSize
            Source          = "Registry"
        }
    }
}

# 2. ZDROJ - APPX / MSIX BALICKY

try {
    $apps = Get-AppxPackage -AllUsers -ErrorAction Stop
}
catch {
    Write-Warning "Nelze nacist AppX vsech uzivatelu."
    $apps = Get-AppxPackage -ErrorAction SilentlyContinue
}

foreach ($app in $apps) {

    $software += [PSCustomObject]@{
        Name            = $app.Name
        Version         = [string]$app.Version
        Publisher       = $app.Publisher
        InstallDate     = $null
        InstallLocation = $app.InstallLocation
        UninstallString = $null
        SizeKB          = $null
        Source          = "AppX"
    }
}

# 3. ZDROJ - PACKAGEMANAGEMENT

try {
    $packages = Get-Package -ErrorAction Stop

    foreach ($package in $packages) {

        $software += [PSCustomObject]@{
            Name            = $package.Name
            Version         = [string]$package.Version
            Publisher       = $null
            InstallDate     = $null
            InstallLocation = $null
            UninstallString = $null
            SizeKB          = $null
            Source          = "PackageManagement: $($package.ProviderName)"
        }
    }
}
catch {
    Write-Warning "PackageManagement nelze kompletne nacist."
}

# 4. ODSTRANENI DUPLICIT A SLOUCENI INFORMACI

$uniqueSoftware = @(
    $software |
    Group-Object {
        $name = ($_.Name -replace '\s+', ' ').Trim().ToLowerInvariant()
        $version = ([string]$_.Version).Trim().ToLowerInvariant()
        "$name|$version"
    } |
    ForEach-Object {

        $group = $_.Group

        $result = [ordered]@{
            Name    = $group[0].Name
            Version = $group[0].Version
        }

        foreach ($field in @(
            "Publisher",
            "InstallDate",
            "InstallLocation",
            "UninstallString",
            "SizeKB"
        )) {
            $result[$field] = $group |
                ForEach-Object { $_.$field } |
                Where-Object {
                    -not [string]::IsNullOrWhiteSpace([string]$_)
                } |
                Select-Object -First 1
        }

        $result["Sources"] = (
            $group.Source | Sort-Object -Unique
        ) -join ", "

        [PSCustomObject]$result
    }
) | Sort-Object Name, Version

# 5. VYPIS NA OBRAZOVKU

$uniqueSoftware |
    Format-Table Name, Version, Publisher, Sources -AutoSize

# 6. EXPORT DO CSV

$csvPath = Join-Path (Get-Location).Path "NainstalovanySoftware.csv"

$uniqueSoftware |
    Export-Csv -Path $csvPath `
        -NoTypeInformation -Encoding UTF8 -Delimiter ";"

Write-Host "Pocet nalezenych zaznamu: $($software.Count)"
Write-Host "Pocet programu po odstraneni duplicit: $($uniqueSoftware.Count)"
Write-Host "Soubor ulozen: $csvPath"
