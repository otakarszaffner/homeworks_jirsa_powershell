# Paleta 16 přednastavených barev terminálu
$colors = @(
    "Black",
    "DarkBlue",
    "DarkGreen",
    "DarkCyan",
    "DarkRed",
    "DarkMagenta",
    "DarkYellow",
    "Gray",
    "DarkGray",
    "Blue",
    "Green",
    "Cyan",
    "Red",
    "Magenta",
    "Yellow",
    "White"
)

for ($i = 0; $i -lt $colors.Count; $i++) {
    $color = $colors[$i]
    $label = "{0,-31}" -f $color

    Write-Host $label -ForegroundColor Gray -BackgroundColor Black -NoNewline
    Write-Host $label -ForegroundColor $color -BackgroundColor Black -NoNewline
    Write-Host $label -ForegroundColor Gray -BackgroundColor $color
}