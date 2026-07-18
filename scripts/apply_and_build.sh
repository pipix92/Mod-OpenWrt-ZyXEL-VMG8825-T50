#!/bin/bash
# apply_and_build.sh
# Applica il porting VMG8825-T50 a un albero OpenWrt e avvia la build.
# Verificato funzionante su hardware reale (WSL Ubuntu) il 2026-07-18.
#
# Prerequisiti (WSL Ubuntu, NON Windows nativo — servono symlink/permessi Unix):
#   sudo apt install -y build-essential clang flex bison g++ gawk \
#     gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
#     python3-setuptools rsync swig unzip zlib1g-dev file wget \
#     libelf-dev ecj fastjar java-propose-classpath python3-dev qemu-utils zstd bc lrzsz picocom

set -e

# CONFIGURA QUESTO PATH → dove hai clonato openwrt
OPENWRT_DIR="${OPENWRT_DIR:-$HOME/openwrt}"

# Path del progetto porting (auto-detect se lo script è dentro scripts/)
PORTING_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# --- FIX WSL: rimuove i path Windows (Git-for-Windows, ecc.) da $PATH ---
# Senza questo, `make` fallisce a fine build con:
#   find: The relative path 'Files/Git/mingw64/bin' is included in the PATH
#   environment variable, which is insecure in combination with the
#   -execdir action of find.
# Causa: WSL eredita il PATH di Windows, e "C:\Program Files\Git\..." con lo
# spazio si spezza in un frammento relativo che GNU find rifiuta di usare.
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "=========================================="
echo " OpenWrt VMG8825-T50 porting: apply+build"
echo "=========================================="
echo "OpenWrt dir : $OPENWRT_DIR"
echo "Porting dir : $PORTING_DIR"
echo ""

if [ ! -d "$OPENWRT_DIR" ]; then
    echo "[!] OpenWrt non trovato in $OPENWRT_DIR"
    echo "    Clonalo con: git clone https://github.com/openwrt/openwrt.git $OPENWRT_DIR"
    exit 1
fi

cd "$OPENWRT_DIR"

echo "[1/6] git fetch/pull master..."
git fetch origin
git checkout main
git pull --ff-only

echo "[2/6] Copia device tree..."
cp "$PORTING_DIR/dts/en751627_zyxel_vmg8825-t50.dts" \
   target/linux/econet/dts/

echo "[3/6] Applica patch image..."
patch -p1 --forward < "$PORTING_DIR/patches/001-add-vmg8825-t50-image.patch" || echo "  (già applicato?)"

echo "[4/6] Applica patch chboot (sperimentale, non ancora testata su hardware)..."
patch -p1 --forward < "$PORTING_DIR/patches/002-add-vmg8825-t50-chboot.patch" || echo "  (già applicato?)"

echo "[5/6] Update feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

echo "[6/6] Seleziona il device e builda..."
make defconfig
# Se ".config" non seleziona già il device, decommenta e adatta:
# echo 'CONFIG_TARGET_econet_en751627_DEVICE_zyxel_vmg8825-t50=y' >> .config
# make defconfig

make -j"$(nproc)" 2>&1 | tee build.log

echo ""
echo "=========================================="
echo " BUILD COMPLETATA"
echo "=========================================="
ls -la bin/targets/econet/en751627/*vmg8825*.trx 2>&1 || echo "[!] nessun .trx prodotto — controlla build.log"
