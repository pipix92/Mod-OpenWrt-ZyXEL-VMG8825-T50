<div align="center">
  <img src="https://service-provider.zyxel.com/sites/default/files/styles/large/public/2020-09/img_vmg8825-t50k_p.png?itok=ZHXKESVr" alt="VMG8825-T50K" width="260">

  <h1>OpenWrt su ZyXEL VMG8825-T50/K</h1>

  <p>
    <b>🇮🇹 Italiano</b> · <a href="README.en.md">🇬🇧 English</a>
  </p>

  <p>
    Porting funzionante di OpenWrt (kernel 6.18) sul modem ZyXEL VMG8825-T50K (SoC EN7516 / EcoNet EN751627).<br>
    Boot completo confermato su hardware reale, incluso WiFi dual-band e overlay persistente su NAND.
  </p>
</div>

---

## Stato del porting

```diff
+ Boot completo fino a shell BusyBox root
+ RAM riconosciuta correttamente (432MB usabili su 512MB fisici)
+ Partizioni NAND corrette (bootloader/romfile/tclinux/tclinux_slave/misc/reservearea)
+ WiFi dual-band funzionante (2x MediaTek MT7615, driver mt76 mainline)
+ USB 3.0 (xHCI) funzionante
+ Overlay persistente su NAND (UBI + UBIFS) — la configurazione sopravvive al reboot
! MAC address WiFi casuale (l'EEPROM in "reservearea" non sembra contenere il MAC — da investigare, forse è in "romfile")
! Password root non impostata di default (fallo con `passwd` dopo il primo boot)
- Ethernet nativo non ancora supportato dal target OpenWrt econet (usa un dongle USB-Ethernet come WAN/LAN)
- Patch "chboot" (switch A/B OS) presente ma non ancora verificata su hardware
```

---

## Crediti

Questo lavoro non parte da zero. Si basa su:

- **[AgostinoA](https://github.com/AgostinoA/OpenWrt-ZyXEL-VMG8825-T50)** — ha avviato il porting nel 2020, raccolto i firmware stock e posto le basi. Questo repo è un fork del suo lavoro.
- **[EcoNet Linux](https://econet-linux.pkt.wiki)** ([Caleb J. DeLisle / cjdelisle](https://github.com/cjdelisle)) — porting mainline del kernel Linux per i SoC EcoNet EN75xx, finanziato NLnet/NGI Zero Core. Fornisce il target `econet/en751627` in OpenWrt (device gemello: `zyxel_ex3301-t0`), i tool `ATENv3` (unlock bootloader) e `en7516_bootloader`.
- **[Th0mas](https://th0mas.nl/2020/03/26/getting-root-on-a-zyxel-vmg8825-t50-router/)** — analisi RCE sul firmware stock (non necessaria per questo porting: qui si usa l'accesso diretto al bootloader via UART).

---

## Hardware

| Componente | Dettaglio |
|---|---|
| SoC | Airoha/EcoNet EN7516 (MIPS 1004Kc, big-endian, quad-core) |
| RAM | 512 MB DDR3-1333 (432 MB dichiarati al kernel, vedi sotto il perché) |
| Flash | Winbond W25M02G, SPI-NAND, 256 MB, SLC |
| WiFi | 2× MediaTek MT7615 (uno 2.4GHz iPA/iLNA, uno 5GHz ePA/eLNA), PCIe separati |
| USB | 1× USB 3.0 (xHCI) |
| Bootloader | ZyXEL zloader v1.4.3, interfaccia comandi `ZHAL>` (AT-command) |
| Console | UART 115200 8N1 su `ttyS0` |

---

## Guida rapida

### 1. Accesso alla console UART
Serve un adattatore USB-TTL **3.3V** (non 5V) collegato ai pad UART sul PCB (TX↔RX incrociati, GND↔GND, **non collegare VCC**). Terminale a 115200 8N1.

### 2. Sblocco del bootloader
Il bootloader ZyXEL richiede una password monouso, generata da un challenge (`ATSE`) via l'algoritmo **ATENv3** ([cjdelisle/ATENv3](https://github.com/cjdelisle/ATENv3)):

```
ZHAL> ATSE VMG8825-T50K
<36 caratteri hex>
```

Sul PC (WSL/Linux, dopo aver clonato e compilato ATENv3):
```bash
./atenv3_passwd <36-char-hex>
```

Poi:
```
ZHAL> ATEN 1,<password>
```

Uno script di comodo è incluso in [`scripts/unlock_bootloader.sh`](scripts/unlock_bootloader.sh) (richiede `atenv3_passwd` compilato da ATENv3, vedi il commento nello script).

⚠️ La password è **valida solo per la sessione corrente** (fino al prossimo riavvio/spegnimento del modem) ed è specifica per il singolo dispositivo (basata su un seed derivato dall'hardware).

### 3. Build di OpenWrt

```bash
git clone https://github.com/openwrt/openwrt.git ~/openwrt
cd ~/openwrt
OPENWRT_DIR=~/openwrt ./scripts/apply_and_build.sh   # dal repo di questo progetto
```
(oppure segui i passi manuali in [`scripts/apply_and_build.sh`](scripts/apply_and_build.sh))

Il target da selezionare in `make menuconfig` è **EcoNet EN75xx MIPS → EN751627 → Zyxel VMG8825-T50**.

**Importante se usi WSL**: senza il fix incluso nello script, la build fallisce all'ultimo passo con un errore criptico di `find -execdir` causato dal `$PATH` di Windows ereditato da WSL. Lo script lo risolve automaticamente.

### 4. Flash via TFTP

Dal prompt bootloader:
```
ZHAL> ATUR firmware.trx
```
Il file richiesto è `openwrt-econet-en751627-zyxel_vmg8825-t50-squashfs-tclinux.trx` (rinominalo `firmware.trx` o come richiesto dal tuo client TFTP).

**Consiglio**: il device ha due slot OS (`tclinux`/`tclinux_slave`, alternati automaticamente ad ogni `ATUR`). Flasha **due volte di seguito** per scrivere lo stesso firmware su entrambi gli slot — evita sorprese legate a quale slot sia effettivamente "attivo" (vedi bug #2 sotto).

### 5. Overlay persistente (una tantum, dalla shell live)

Il device usa NAND SPI, che richiede UBI (non il classico JFFS2 su blocco grezzo). Il device tree già predispone il bootarg `ubi.mtd=misc`, ma il volume UBI va creato una sola volta:

```sh
ubiformat /dev/mtd10 -y
ubiattach /dev/ubi_ctrl -m 10
ubimkvol /dev/ubi0 -N rootfs_data -m
```
(verifica con `cat /proc/mtd | grep misc` che la partizione "misc" sia effettivamente `mtd10` sul tuo device — di solito sì, ma controlla.)

Dopo questo unico passaggio, la configurazione (LuCI/UCI, WiFi, ecc.) sopravvive ai riavvii.

---

## I tre bug reali trovati (e le fix)

Questi non sono ipotesi: sono stati diagnosticati e verificati su hardware reale, leggendo il kernel log seriale passo per passo.

### Bug 1 — Kernel bloccato subito dopo l'init della cache
**Sintomo**: il boot si ferma sempre dopo `Readback ErrCtl register=...`, prima di `Built 1 zonelists`, indipendentemente da come viene flashato il firmware.
**Causa**: il device tree dichiarava l'intera RAM fisica (512MB, `reg = <0x0 0x20000000>`), il cui limite superiore coincide esattamente con l'inizio della finestra MMIO fissa della PCIe0 (`0x20000000`, vedi `en751627.dtsi`). Il training DDR3 del bootloader vendor non è affidabile fino a quel limite esatto.
**Fix**: RAM dichiarata a 432MB (`reg = <0x0 0x1b000000>`) — lo stesso valore che il kernel stock ZyXEL (3.18.21) usava realmente su questo hardware (80MB riservati per DSP/VoIP+WiFi), non una stima a caso.

### Bug 2 — Kernel panic nel montare la root filesystem
**Sintomo**: `VFS: Unable to mount root fs on unknown-block(0,0)`.
**Causa**: la squashfs rootfs, per il formato immagine usato da questo bootloader (`tclinux-trx.sh`), inizia **sempre** a un offset fisso di 4MiB dall'inizio della partizione kernel+rootfs — ma il device tree non aveva nessuna sotto-partizione che lo dichiarasse.
**Fix**: aggiunta una partizione annidata con `linux,rootfs;` al giusto offset (`tclinux_start + 0x400000`), esattamente come fa il device di riferimento `zyxel_ex3301-t0`.

### Bug 3 — Overlay non persistente (sempre tmpfs)
**Sintomo**: ogni configurazione si perde ad ogni riavvio.
**Causa**: il kernel ha JFFS2 disabilitato (`# CONFIG_JFFS2_FS is not set`) — su NAND serve UBI, non JFFS2 su blocco grezzo.
**Fix**: bootarg `ubi.mtd=misc` (riusa la partizione vendor "misc", inutilizzata da OpenWrt) + creazione una tantum del volume UBI `rootfs_data` (vedi sopra). Confermato funzionante: la configurazione sopravvive al reboot.

---

## Struttura del repo

```
dts/en751627_zyxel_vmg8825-t50.dts   ← device tree (RAM, partizioni, WiFi, UBI)
patches/001-add-vmg8825-t50-image.patch    ← aggiunge il device a target/linux/econet/image/en751627.mk
patches/002-add-vmg8825-t50-chboot.patch   ← switch OS A/B (sperimentale, non testato)
scripts/unlock_bootloader.sh   ← wrapper per generare la password ATEN
scripts/apply_and_build.sh     ← applica patch + builda (include fix WSL)
```

## Licenza

GPL-2.0-only OR BSD-2-Clause, in linea con i file DTS/kernel di OpenWrt da cui questo lavoro deriva.

## Contribuire

Pull request benvenute — in particolare su: driver ethernet nativo, MAC address WiFi dall'EEPROM corretto, verifica della patch chboot su hardware.
