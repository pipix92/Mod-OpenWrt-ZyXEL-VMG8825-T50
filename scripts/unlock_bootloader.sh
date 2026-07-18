#!/bin/bash
# unlock_bootloader.sh
# Wrapper per generare la password ATENv3 dal challenge ATSE del bootloader.

set -e

# Path al binario compilato
ATENV3="$(cd "$(dirname "$0")/../../03_exploits/ATENv3" && pwd)/atenv3_passwd"

if [ ! -x "$ATENV3" ]; then
    echo "[!] atenv3_passwd non compilato. Compilalo con:"
    echo "    cd $(dirname "$ATENV3")"
    echo "    gcc -o atenv3_passwd atenv3_passwd.c"
    exit 1
fi

if [ -z "$1" ]; then
    cat <<EOF
Usage: $0 <ATSE-hex-36-char>

Come usarlo:
  1. Collegati al bootloader del VMG8825-T50 via UART
  2. Al prompt bldr> scrivi: ATSE
  3. Copia i 36 caratteri hex che ti restituisce
  4. Lancia:   $0 <36-char-hex>
  5. Copia la password
  6. Al prompt bldr>: ATEN <password>

Esempio:
  bldr> ATSE
  2400C00C09503316E000148493987B03118E
  bldr>

  \$ $0 2400C00C09503316E000148493987B03118E
  363943360710703246723488897955

  bldr> ATEN 363943360710703246723488897955
  Password correct.
  bldr>
EOF
    exit 0
fi

PWD=$("$ATENV3" "$1")
echo ""
echo "=========================================="
echo " Password bootloader per il tuo modem"
echo "=========================================="
echo "  ATEN $PWD"
echo "=========================================="
echo ""
echo "Copia la password e incollala nel prompt bldr> del modem."
