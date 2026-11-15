# Lab 5 — Encoding forensics

Name: Damir Niyazbek · Date: 15 November 2026 · Tools: Git Bash on Windows 11 (`file`, `xxd`, `iconv`), PowerShell 5.1, Excel, LibreOffice Calc

## What I received

`evidence/staff-broken.csv`, 852 bytes, 16 lines (header + 15 staff). Kept untouched as evidence
(SHA-256 `fecc66e3d7ab4e51f7d72f3e5107a36fa52215d04e1567c13bf65defcce2e41f`, the same before and after the fix).

- **Excel** (double-click, [excel.png](evidence/excel.png)): every line in column A. Russian words read fine, but every
  Kazakh letter is wrong: `Әбдірахманова` → `Јбдірахманова`, `Қасымов` → `Ќасымов`, `Нұрлан` → `Нўрлан`, `Өскемен` → `Ґскемен`.
- **Terminal** (PowerShell `cat`, [powershell.png](evidence/powershell.png)): the same picture — Russian OK, Kazakh letters
  replaced by other Cyrillic letters (`Ј`, `Ќ`, `ў`, `Ґ`).
- **LibreOffice Calc** ([libreoffice.png](evidence/libreoffice.png)): opened via File → Open, import dialog left at
  its defaults. Calc split the columns correctly on `;` (A–F), but the default character set was the system ANSI
  code page, Cyrillic (Windows-1251), so the Kazakh letters broke the same way as in Excel: `Јбдірахманова`,
  `Ќасымов`, `Гілнўр`, `Ќараѓанды`, `Ґскемен`.

Russian text being correct while Kazakh is wrong already hints at a code page that is *almost* Windows-1251, but not quite.

## Diagnosis (made before the fix)

- `file` said: `Non-ISO extended-ASCII text, with CRLF line terminators` ([file-before.txt](evidence/file-before.txt))
  → one byte per letter, some legacy code page; `file` cannot tell which.
- First 16 bytes: `49 44 3B D4 E0 EC E8 EB E8 FF 3B C8 EC FF 3B CE` = `ID;Фамилия;Имя;О` ([hexdump-before.txt](evidence/hexdump-before.txt))

| Field | Value | Because (bytes) |
|---|---|---|
| **Encoding** | **KZ-1048** (RK1048 / STRK1048-2002, the Kazakh variant of Windows-1251) | Cyrillic is one byte per letter: `Ф` = `D4`, `а` = `E0`, `я` = `FF` — the Windows-1251 layout (not KOI8-R, where `а` = `C1`). But line 2 starts `31 30 31 3B A3 E1 E4 B3 F0 …` = `101;Әбдір…`: `A3` is `Ә` in KZ-1048 and `Ј` in Windows-1251. |
| **Line ending** | **CRLF** | Line 1 ends `… E4 0D 0A` at offset 0x24–0x25; 16 `0D` bytes for 16 lines. |
| **BOM** | **none** | File starts `49 44` = `ID`, not `EF BB BF` / `FF FE` / `FE FF`. |
| **Separator** | **`;`** | `3B` between fields. No field contains a `,`. |

Proof by trial decoding — the one where *every* name reads correctly wins:

```
$ iconv -f WINDOWS-1251 -t UTF-8 evidence/staff-broken.csv | sed -n '2p;4p'
101;Јбдірахманова;Аружан;Бухгалтерия;Главный бухгалтер;Алматы
103;Ќасымов;Нўрлан;Продажи;Менеджер по продажам;Астана

$ iconv -f RK1048 -t UTF-8 evidence/staff-broken.csv | sed -n '2p;4p'
101;Әбдірахманова;Аружан;Бухгалтерия;Главный бухгалтер;Алматы
103;Қасымов;Нұрлан;Продажи;Менеджер по продажам;Астана
```

**Summary: KZ-1048, CRLF line endings, no BOM, `;` separator.**

## Decisions for the fixed file

| Question | Choice | Reason |
|---|---|---|
| Encoding | UTF-8 | The target of the lab; holds all Kazakh letters. |
| BOM | **Added** (`EF BB BF`) | The brief requires Excel by double-click. Without a BOM Excel reads a CSV in the system ANSI code page (Windows-1251 here) and garbles UTF-8. The cost — scripts may see `﻿ID` as the first header — is acceptable; a script can strip it (`sed '1s/^\xEF\xBB\xBF//'`). |
| Line ending | **Kept CRLF** | The file is for Windows/Excel users; `cat` and LibreOffice handle CRLF fine. |
| Separator | **Changed `;` → `,`** | Excel splits a double-clicked CSV by the Windows *list separator*, which on this machine (`en-GB`) is `,`. With `;` all data went into column A. The swap is lossless because no field contains a comma (the script checks this). |

## Fix

[scripts/fix.sh](scripts/fix.sh), run from `labs/lab05-encoding/` with `sh scripts/fix.sh`:

```sh
#!/bin/sh
set -e
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv

if grep -q ',' "$in"; then echo "source contains commas - not swapping separator" >&2; exit 1; fi

{
  printf '\357\273\277'                  # BOM EF BB BF: Excel detects UTF-8 on double-click
  iconv -f RK1048 -t UTF-8 "$in" |       # encoding: KZ-1048 -> UTF-8
    tr ';' ','                           # separator: ';' -> ','
} > "$out"
# Line endings: the source is already CRLF; iconv and tr keep them.
```

PowerShell/.NET was not an option: KZ-1048 is not available in .NET's `GetEncoding`, so the fix uses `iconv` from Git Bash.

## Verification

[file-after.txt](evidence/file-after.txt):

```
$ file evidence/staff-fixed.csv
evidence/staff-fixed.csv: CSV Unicode text, UTF-8 (with BOM) text

$ xxd evidence/staff-fixed.csv | head -n 1
00000000: efbb bf49 442c d0a4 d0b0 d0bc d0b8 d0bb  ...ID,..........
```

- Starts with the BOM `EF BB BF`, Cyrillic is now `D0 xx` / `D1 xx` pairs (`Ф` = `D0 A4`).
- CRLF kept: 16 `0D` bytes, file ends `0D 0A`. (Newer `file` reports it as "CSV text" and no longer prints
  "with CRLF line terminators", so the line endings are proven with `tr -cd '\r' | wc -c` and `tail -c 4 | xxd`.)
- Excel check through COM (same as double-click): `A1=ID`, `B1=Фамилия`, `B2=Әбдірахманова`, `C9=Гүлнұр`,
  `F9=Қарағанды` — each field in its own column, Kazakh letters correct.

Screenshot with all three applications, all showing `Әбдірахманова`, `Қасымов`, `Өмірзақова`, `Қарағанды`,
`Өскемен` correctly: [opens-correctly.png](evidence/opens-correctly.png)

- **Excel** (double-click): one field per column (A–F), header row `ID | Фамилия | Имя | …`.
- **LibreOffice Calc** (import dialog: Character set Unicode (UTF-8), separator Comma): one field per column,
  Kazakh letters correct.
- **Terminal** (PowerShell `cat` in `labs/lab05-encoding`): every line decoded correctly.

## What did not work the first time

1. **First fixed file had the right encoding but everything in one column in Excel.** I kept the original `;`
   separator. Excel decoded the UTF-8 correctly (BOM worked) but cell A1 contained the whole line
   `ID;Фамилия;Имя;…`. Cause: Excel uses the Windows list separator, which on my `en-GB` profile is `,`
   (`(Get-Culture).TextInfo.ListSeparator` → `,`).
2. **`sep=;` as a first line made it worse.** Columns split correctly, but Excel then *ignored the BOM* and read
   the file as Windows-1251: `Фамилия` became `Р¤Р°РјРёР»РёСЏ`. So the `sep=` hint and the BOM cannot be used together.
   Final solution: swap the separator to `,` in the script (safe — no commas in the data).
3. **LibreOffice opened the CSV in Writer, not Calc.** Double-clicking / opening from the Start Center gave a
   plain-text Writer document with no import dialog, so there was no character set or separator to choose. I
   retook both LibreOffice screenshots by opening the file from inside Calc (File → Open).
4. Windows-1251 was the obvious first guess (`file` + Russian text looked fine), but it turned every `Ә` into `Ј`
   and `Қ` into `Ќ`. Only the bytes of a Kazakh letter (`A3`) showed it was KZ-1048.

## Evidence

- [evidence/staff-broken.csv](evidence/staff-broken.csv) — the original, unchanged
- [evidence/staff-fixed.csv](evidence/staff-fixed.csv) — output of `scripts/fix.sh`
- [evidence/file-before.txt](evidence/file-before.txt) — `file` on the original: extended-ASCII, CRLF
- [evidence/hexdump-before.txt](evidence/hexdump-before.txt) — first 8 lines of hex: no BOM, single-byte Cyrillic, `0D 0A`
- [evidence/file-after.txt](evidence/file-after.txt) — `file` + hex + CRLF count on the fixed file: UTF-8 with BOM, CRLF
- [evidence/excel.png](evidence/excel.png), [evidence/powershell.png](evidence/powershell.png), [evidence/libreoffice.png](evidence/libreoffice.png) — how the original looked in Excel, a terminal and LibreOffice Calc (Kazakh letters wrong in all three)
- [evidence/opens-correctly.png](evidence/opens-correctly.png) — fixed file in Excel, LibreOffice Calc and a terminal, all names correct
