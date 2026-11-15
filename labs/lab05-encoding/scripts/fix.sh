#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (iconv name RK1048) to UTF-8.
# Output: UTF-8 with BOM, CRLF line endings, comma separator.
# Run from labs/lab05-encoding/:  sh scripts/fix.sh
set -e
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv

# Safety: the ';' -> ',' swap is only lossless if no field already contains a comma.
if grep -q ',' "$in"; then echo "source contains commas - not swapping separator" >&2; exit 1; fi

{
  printf '\357\273\277'                  # BOM EF BB BF: Excel detects UTF-8 on double-click
  iconv -f RK1048 -t UTF-8 "$in" |       # encoding: KZ-1048 -> UTF-8
    tr ';' ','                           # separator: ';' -> ',' (Windows list separator here)
} > "$out"
# Line endings: the source is already CRLF (0D 0A); iconv and tr keep them, nothing to do.
