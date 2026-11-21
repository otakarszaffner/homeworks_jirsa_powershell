# Práce s řetězci v PowerShellu

Projekt obsahuje dva samostatné skripty pro práci s textem. Oba fungují ve **Windows PowerShellu 5.1** i v **PowerShellu 7+**.

## Zadání

1. Vytvořit program v PowerShellu, který ověří, zda je zadaný text palindrom.
2. Vytvořit program, kterému lze předat text a který vypíše:
   - počet znaků s mezerami,
   - počet znaků bez mezer,
   - počet samohlásek,
   - počet slov.

> K testu lze použít text „Lewis Powell působil jako právník specializující se na tabákový průmysl ve společnosti Philip Morris. Byl pověřen, aby pro Americkou obchodní komoru vypracoval důvěrný dokument s cílem obnovit a rozšířit vliv korporací.“

---

## Obsah projektu

```text
powershell_retezce/
├── palindrom.ps1
├── analyza-textu.ps1
└── README.md
```

## 1. Kontrola palindromu

**Skript:** `palindrom.ps1`

Skript ověří, zda se text čte stejně zleva doprava i zprava doleva.

### Postup

1. Načte text z parametru `-Text` nebo se na něj zeptá přímo v terminálu.
2. Odstraní diakritiku, mezery a interpunkci a převede písmena na malá.
3. Číslice zachová.
4. Obrátí pořadí znaků a porovná ho s očištěným textem.
5. Vypíše `ANO` nebo `NE`.

### Testovací příklady

| Text | Očekávaný výsledek |
|---|---|
| Jelenovi pivo nelej | ANO |
| Kobyla má malý bok | ANO |
| Kupředu udeř puk | ANO |
| Dal kopat Ota poklad | ANO |
| Toto není palindrom | NE |

### Příklad spuštění

```powershell
.\palindrom.ps1 -Text 'Kobyla má malý bok'
```

```text
Zadaný text: Kobyla má malý bok
Výsledek: ANO - text je palindrom.
```

---

## 2. Analýza textu

**Skript:** `analyza-textu.ps1`

Skript vypíše:

| Hodnota | Význam |
|---|---|
| Počet znaků s mezerami | Všechny znaky včetně mezer a interpunkce |
| Počet znaků bez mezer | Všechny znaky kromě mezer, tabulátorů a konců řádků |
| Počet samohlásek | `a, e, i, o, u, y, á, é, í, ó, ú, ů, ý` bez ohledu na velikost písmen |
| Počet slov | Skupiny znaků oddělené mezerami nebo jinými bílými znaky |

### Testovací text

```text
Lewis Powell působil jako právník specializující se na tabákový průmysl ve společnosti Philip Morris. Byl pověřen, aby pro Americkou obchodní komoru vypracoval důvěrný dokument s cílem obnovit a rozšířit vliv korporací.
```

### Výsledek

```text
Počet znaků s mezerami: 219
Počet znaků bez mezer: 189
Počet samohlásek:      75
Počet slov:            31
```

> [!NOTE]
> Uvedených 77 samohlásek není správně při obvyklém českém vymezení samohlásek. Výsledek je **75**. Hodnota 77 by vznikla, kdyby se k nim započítala i dvě písmena `w` ze slov Lewis a Powell, ale `w` není samohláska.

---

## Možné problémy a omezení

- **Chybná diakritika:** Skripty jsou uloženy v UTF-8 s BOM, aby je správně přečetl Windows PowerShell 5.1. Terminál by měl používat písmo podporující češtinu.
- **Nevhodné uvozovky:** Víceslovné vstupy v parametru je nutné uzavřít do jednoduchých uvozovek `'...'`. Pokud text obsahuje apostrof, v jednoduchých uvozovkách ho musíme zapsat dvakrát: `'It''s OK'`.
- **Prázdný vstup:** Skripty ukončí zpracování s chybovou zprávou.
- **Vstup s několika řádky:** `Read-Host` načte pouze jeden řádek. Pro soubor lze použít například:

  ```powershell
  .\analyza-textu.ps1 -Text (Get-Content -Raw -Encoding UTF8 .\text.txt)
  ```

- **Definice slova:** Počítají se bloky oddělené bílými znaky. Dvě slova spojená čárkou bez mezery se proto započítají jako jeden blok.
- **Definice znaku:** `.Length` měří jednotky UTF-16. Některé emoji nebo složené znaky Unicode mohou být započítány jako více jednotek.
- **Palindrom s diakritikou:** Diakritika se záměrně ignoruje, takže například „Kobyla má malý bok“ vyjde jako palindrom.