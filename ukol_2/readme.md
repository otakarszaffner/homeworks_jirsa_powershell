# Zadání: 
  Vytvořte skript, který vykreslí paletu 16 odstínů barev přednastavených v terminálu.

<img width="658" height="465" alt="image" src="https://github.com/user-attachments/assets/82a72f04-8892-4e07-a363-3061ca855166" />

# Řešení

Níže je jednoduchý PowerShell skript, který vykreslí 16 standardních barev terminálu v mřížce 4x4. Každá barva má svůj název a je vypsána v daném foregroundu, takže v terminálu je jasně vidět, jak vypadá.

```powershell
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

Write-Host "Paleta barev terminálu" -ForegroundColor White -BackgroundColor Black
Write-Host ""

for ($i = 0; $i -lt $colors.Count; $i++) {
    $color = $colors[$i]
    $label = "[{0, -10}]" -f $color

    Write-Host $label -ForegroundColor $color -NoNewline

    if (($i + 1) % 4 -eq 0) {
        Write-Host ""
    }
}

Write-Host ""
Write-Host "Konec palety" -ForegroundColor White
