# Zadání: 
Vytvořte skript, který vykreslí paletu 16 odstínů barev přednastavených v terminálu.

<img width="658" height="465" alt="image" src="https://github.com/user-attachments/assets/82a72f04-8892-4e07-a363-3061ca855166" />

# Řešení:
Řešením je PowerShell skript [`pallet.ps1`](./pallet.ps1).

Skript vypíše všech 16 přednastavených barev terminálu po jednom řádku. Každý řádek obsahuje tři ukázky názvu barvy: šedý text na černém pozadí, text vykreslený danou barvou na černém pozadí a šedý text na pozadí dané barvy.

# Vysvětlení:

- Pole `$colors` obsahuje názvy 16 barev, které PowerShell přijímá jako hodnoty parametrů `-ForegroundColor` a `-BackgroundColor`.
- Cyklus `for` prochází pole od prvního prvku až po poslední. V každém průchodu uloží aktuální název barvy do proměnné `$color`.
- Řetězec `$label` se vytvoří pomocí formátovacího výrazu `"{0,-31}" -f $color`. Název se zarovná doleva do šířky 31 znaků, takže jednotlivé barevné ukázky tvoří přehledné sloupce.
- První `Write-Host` vypíše název šedým písmem na černém pozadí. Parametr `-NoNewline` ponechá kurzor na stejném řádku.
- Druhý `Write-Host` vypíše stejný název barvou z proměnné `$color`, také na černém pozadí, a pomocí `-NoNewline` pokračuje na témže řádku.
- Třetí `Write-Host` zobrazí název šedým písmem na pozadí nastaveném podle `$color`. Protože zde `-NoNewline` není, po ukázce přejde na další řádek.