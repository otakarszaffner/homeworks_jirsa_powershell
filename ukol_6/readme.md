# PowerShell providers

## Zadání

1. Vytvořte skript, který vypíše co nejpodrobnější seznam nainstalovaného softwaru ve Windows. Najděte alespoň tři různé zdroje informací o nainstalovaném softwaru, ale nepoužívejte rozhraní WMI/CIM. Veškerý nalezený software spojte do jednoho seznamu a odstraňte duplicity.
2. Zjistěte, zda je před přihlášením uživatele zapnutá klávesa NumLock. Pokud není, proveďte potřebnou změnu.

## Řešení

### Úkol 1: Seznam nainstalovaného softwaru

Skript používá tři různé zdroje informací o nainstalovaném softwaru: registr Windows, AppX/MSIX a PackageManagement. Výsledky spojuje do jednoho seznamu, odstraňuje duplicity a exportuje do souboru CSV. WMI ani CIM nepoužívá.

- **Skript:** `InstalledAplications.ps1`
- **Soubor s výsledky:** `NaistalovanySoftware.csv`

### Úkol 2: NumLock při přihlášení

Skript kontroluje hodnotu `InitialKeyboardIndicators` v registru pro přihlašovací obrazovku. Pokud hodnota neoznačuje zapnutý NumLock, skript ji upraví. Provedení změny se ověří restartem počítače.

- **Skript:** `IsNumLockUp.ps1`
