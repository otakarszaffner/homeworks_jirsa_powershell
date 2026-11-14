# PowerShell – vytvoření, záloha a obnova aliasů

## Zadání

Vytvořte alias `np` pro `notepad.exe` a alias `ct` pro `control.exe`. Oba aliasy zazálohujte do formátů JSON a XML. Potom aliasy smažte a obnovte je ze souboru JSON. Následně je znovu smažte a obnovte ze souboru XML.

## Soubory

- **`aliasy_zaloha_obnova.ps1`** – PowerShell skript, který všechny požadované operace provede automaticky.
- **`readme.md`** – tento dokument s postupem a vysvětlením jednotlivých příkazů.

Při spuštění skriptu vzniknou ve **stejné složce jako skript** ještě dva záložní datové soubory:

- `aliasy.json` – záloha obou aliasů ve formátu JSON.
- `aliasy.xml` – záloha obou aliasů ve formátu PowerShell CLIXML (platný formát XML).

## Co skript provádí

### 1. Vytvoření aliasů

```powershell
Set-Alias -Name np -Value notepad.exe -Force
Set-Alias -Name ct -Value control.exe -Force
```

- `Set-Alias` vytvoří zkrácený název příkazu.
- `np` spouští Poznámkový blok (Notepad).
- `ct` spouští Ovládací panely (Control Panel).
- Parametr `-Force` umožňuje přepsat existující alias se stejným názvem, pokud to jeho nastavení dovoluje.

### 2. Záloha do JSON a XML

Skript nejprve načte oba vytvořené aliasy příkazem `Get-Alias`. Pro každý uloží dvě vlastnosti:

- `Name` – název aliasu (`np` nebo `ct`).
- `Definition` – cílový příkaz (`notepad.exe` nebo `control.exe`).

Zápis do JSON provádí kombinace `ConvertTo-Json` a `Set-Content`. XML zálohu vytvoří `Export-Clixml`.

**Příklad obsahu souboru `aliasy.json`:**

```json
[
  {
    "Name": "np",
    "Definition": "notepad.exe"
  },
  {
    "Name": "ct",
    "Definition": "control.exe"
  }
]
```

**CLIXML** je formát XML určený pro serializaci PowerShell objektů. Obsah souboru `aliasy.xml` tedy není stejný jako JSON, ale uchovává tytéž dvě vlastnosti obou aliasů.

### 3. První smazání aliasů

```powershell
Remove-Item -Path Alias:np -Force
Remove-Item -Path Alias:ct -Force
```

`Alias:` je PowerShell provider zpřístupňující aliasy jako položky virtuální jednotky. `Remove-Item` vybrané položky odstraní. Skript zároveň kontroluje, že odstranění proběhlo.

### 4. Obnova z JSON

```powershell
$zJson = Get-Content -Path .\aliasy.json -Raw | ConvertFrom-Json
foreach ($polozka in $zJson) {
    Set-Alias -Name $polozka.Name -Value $polozka.Definition -Force
}
```

- `Get-Content -Raw` načte celý soubor JSON.
- `ConvertFrom-Json` převede JSON zpět na PowerShell objekty.
- `Set-Alias` podle načtených hodnot znovu vytvoří oba aliasy.

Samotný dodaný skript používá úplné cesty k souborům a před obnovou navíc kontroluje obsah zálohy.

### 5. Druhé smazání aliasů

Skript oba aliasy znovu odstraní stejnými příkazy jako v kroku 3. Následně opět ověří jejich nepřítomnost.

### 6. Obnova z XML

```powershell
$zXml = Import-Clixml -Path .\aliasy.xml
foreach ($polozka in $zXml) {
    Set-Alias -Name $polozka.Name -Value $polozka.Definition -Force
}
```

- `Import-Clixml` načte data ze souboru XML a obnoví je do podoby objektů.
- `Set-Alias` podle těchto objektů vytvoří aliasy znovu.

Také v této části skutečný skript ověřuje obsah souboru a správnost obnovených aliasů.

### 7. Závěrečná kontrola

Skript vypíše:

```powershell
Get-Alias -Name np, ct
```

**Očekávaný výsledek** (pořadí řádků se může lišit):

```text
CommandType     Name     Definition
-----------     ----     ----------
Alias           np       notepad.exe
Alias           ct       control.exe
```

V otevřeném PowerShellu, lze oba aliasy také vyzkoušet:

```powershell
np    # Otevře Poznámkový blok
ct    # Otevře Ovládací panely
```

## Kontrola splnění zadání

| Krok | Požadavek | Výsledek |
|---|---|---|
| 1 | Vytvoření aliasu `np` | `notepad.exe` |
| 2 | Vytvoření aliasu `ct` | `control.exe` |
| 3 | Záloha obou aliasů do JSON | `aliasy.json` |
| 4 | Záloha obou aliasů do XML | `aliasy.xml` |
| 5 | Smazání obou aliasů | `Remove-Item` |
| 6 | Obnova obou aliasů z JSON | `ConvertFrom-Json` + `Set-Alias` |
| 7 | Opětovné smazání obou aliasů | `Remove-Item` |
| 8 | Obnova obou aliasů z XML | `Import-Clixml` + `Set-Alias` |
| 9 | Ověření výsledku | `Get-Alias` a automatické kontroly |

## Závěr

PowerShell skript provede celé zadání automaticky: vytvoří aliasy, uloží je do dvou různých formátů, dvakrát je smaže a obnoví je postupně z JSON a XML. Po úspěšném dokončení jsou v aktuálním rozsahu skriptu oba aliasy obnovené a lze je ověřit příkazem `Get-Alias`.
