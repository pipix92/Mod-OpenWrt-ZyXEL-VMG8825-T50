<div align="center">
  <img src="https://service-provider.zyxel.com/sites/default/files/styles/large/public/2020-09/img_vmg8825-t50k_p.png?itok=ZHXKESVr" alt="VMG8825-T50K" width="260">

  <h1>OpenWrt on ZyXEL VMG8825-T50/K</h1>

  <p>
    <a href="README.md">🇮🇹 Italiano</a> · <b>🇬🇧 English</b>
  </p>

  <p>
    Working port of OpenWrt (kernel 6.18) for the ZyXEL VMG8825-T50K modem (EN7516 SoC / EcoNet EN751627).<br>
    Full boot confirmed on real hardware, including dual-band WiFi and a persistent NAND overlay.
  </p>
</div>

---

## Port status

```diff
+ Full boot to root BusyBox shell
+ RAM correctly recognized (432MB usable out of 512MB physical)
+ Correct NAND partition table (bootloader/romfile/tclinux/tclinux_slave/misc/reservearea)
+ Dual-band WiFi working (2x MediaTek MT7615, mainline mt76 driver)
+ USB 3.0 (xHCI) working
+ Persistent NAND overlay (UBI + UBIFS) — config survives reboot
! Random WiFi MAC address (the EEPROM in "reservearea" doesn't seem to hold the MAC — needs investigation, possibly stored in "romfile" instead)
! Root password not set by default (run `passwd` after first boot)
- Native Ethernet not yet supported by the OpenWrt econet target (use a USB-Ethernet dongle as WAN/LAN)
- "chboot" patch (A/B OS switching) present but not yet verified on hardware
```

---

## Credits

This work doesn't start from scratch. It builds on:

- **[AgostinoA](https://github.com/AgostinoA/OpenWrt-ZyXEL-VMG8825-T50)** — started this port in 2020, collected the stock firmware dumps, and laid the groundwork. This repo is a fork of his work.
- **[EcoNet Linux](https://econet-linux.pkt.wiki)** ([Caleb J. DeLisle / cjdelisle](https://github.com/cjdelisle)) — mainline Linux kernel port for EcoNet EN75xx SoCs, funded by NLnet/NGI Zero Core. Provides the `econet/en751627` OpenWrt target (sibling device: `zyxel_ex3301-t0`), the `ATENv3` bootloader-unlock tool, and `en7516_bootloader`.
- **[Th0mas](https://th0mas.nl/2020/03/26/getting-root-on-a-zyxel-vmg8825-t50-router/)** — RCE research on the stock firmware (not needed for this port: here we use direct UART bootloader access instead).

---

## Hardware

| Component | Detail |
|---|---|
| SoC | Airoha/EcoNet EN7516 (MIPS 1004Kc, big-endian, quad-core) |
| RAM | 512 MB DDR3-1333 (432 MB declared to the kernel — see why below) |
| Flash | Winbond W25M02G, SPI-NAND, 256 MB, SLC |
| WiFi | 2× MediaTek MT7615 (one 2.4GHz iPA/iLNA, one 5GHz ePA/eLNA), separate PCIe links |
| USB | 1× USB 3.0 (xHCI) |
| Bootloader | ZyXEL zloader v1.4.3, `ZHAL>` AT-command interface |
| Console | UART 115200 8N1 on `ttyS0` |

---

## Quick start

### 1. UART console access
You need a **3.3V** (not 5V) USB-TTL adapter wired to the UART pads on the PCB (cross TX↔RX, GND↔GND, **do not connect VCC**). Terminal at 115200 8N1.

### 2. Unlocking the bootloader
The ZyXEL bootloader requires a one-time password, generated from a challenge (`ATSE`) via the **ATENv3** algorithm ([cjdelisle/ATENv3](https://github.com/cjdelisle/ATENv3)):

```
ZHAL> ATSE VMG8825-T50K
<36-char hex>
```

On your PC (WSL/Linux, after cloning and building ATENv3):
```bash
./atenv3_passwd <36-char-hex>
```

Then:
```
ZHAL> ATEN 1,<password>
```

A convenience wrapper is included in [`scripts/unlock_bootloader.sh`](scripts/unlock_bootloader.sh) (requires the compiled `atenv3_passwd` binary from ATENv3, see the comment in the script).

⚠️ The password is **only valid for the current session** (until the modem's next reboot/power-off) and is device-specific (derived from a hardware-based seed).

### 3. Building OpenWrt

```bash
git clone https://github.com/openwrt/openwrt.git ~/openwrt
cd ~/openwrt
OPENWRT_DIR=~/openwrt ./scripts/apply_and_build.sh   # from this project's repo
```
(or follow the manual steps in [`scripts/apply_and_build.sh`](scripts/apply_and_build.sh))

The target to select in `make menuconfig` is **EcoNet EN75xx MIPS → EN751627 → Zyxel VMG8825-T50**.

**Important if you're using WSL**: without the fix already included in the script, the build fails at the very last step with a cryptic `find -execdir` error caused by WSL inheriting Windows' `$PATH`. The script handles this automatically.

### 4. Flashing via TFTP

From the bootloader prompt:
```
ZHAL> ATUR firmware.trx
```
The file you need is `openwrt-econet-en751627-zyxel_vmg8825-t50-squashfs-tclinux.trx` (rename it to `firmware.trx` or whatever your TFTP client expects).

**Tip**: the device has two OS slots (`tclinux`/`tclinux_slave`, automatically alternated on every `ATUR`). Flash **twice in a row** to write the same firmware to both slots — this avoids surprises related to which slot is actually "active" (see bug #2 below).

### 5. Persistent overlay (one-time, from the live shell)

This device uses SPI-NAND, which requires UBI (not classic JFFS2 on a raw block device). The device tree already sets the `ubi.mtd=misc` bootarg, but the UBI volume itself must be created once:

```sh
ubiformat /dev/mtd10 -y
ubiattach /dev/ubi_ctrl -m 10
ubimkvol /dev/ubi0 -N rootfs_data -m
```
(verify with `cat /proc/mtd | grep misc` that the "misc" partition is indeed `mtd10` on your unit — it usually is, but check.)

After this one-time step, configuration (LuCI/UCI, WiFi, etc.) survives reboots.

---

## The three real bugs found (and their fixes)

These aren't guesses — they were diagnosed and verified on real hardware by reading the serial kernel log step by step.

### Bug 1 — Kernel hangs right after cache init
**Symptom**: boot always stops after `Readback ErrCtl register=...`, before `Built 1 zonelists`, no matter how the firmware was flashed.
**Cause**: the device tree declared the full physical RAM (512MB, `reg = <0x0 0x20000000>`), whose upper bound lands exactly on the start of PCIe0's fixed MMIO window (`0x20000000`, see `en751627.dtsi`). The vendor bootloader's DDR3 training isn't reliable all the way up to that exact boundary.
**Fix**: RAM declared as 432MB (`reg = <0x0 0x1b000000>`) — the same value the stock ZyXEL kernel (3.18.21) actually used on this hardware (80MB reserved for DSP/VoIP+WiFi), not an arbitrary guess.

### Bug 2 — Kernel panic mounting the root filesystem
**Symptom**: `VFS: Unable to mount root fs on unknown-block(0,0)`.
**Cause**: for the image format this bootloader uses (`tclinux-trx.sh`), the squashfs rootfs **always** starts at a fixed 4MiB offset from the start of the kernel+rootfs partition — but the device tree had no sub-partition declaring this.
**Fix**: added a nested partition with `linux,rootfs;` at the correct offset (`tclinux_start + 0x400000`), exactly like the reference `zyxel_ex3301-t0` device does.

### Bug 3 — Non-persistent overlay (always tmpfs)
**Symptom**: every configuration change is lost on reboot.
**Cause**: the kernel has JFFS2 disabled (`# CONFIG_JFFS2_FS is not set`) — NAND needs UBI, not JFFS2 on a raw block device.
**Fix**: `ubi.mtd=misc` bootarg (reusing the unused vendor "misc" partition) + one-time creation of the `rootfs_data` UBI volume (see above). Confirmed working: config now survives reboot.

---

## Repo layout

```
dts/en751627_zyxel_vmg8825-t50.dts   ← device tree (RAM, partitions, WiFi, UBI)
patches/001-add-vmg8825-t50-image.patch    ← adds the device to target/linux/econet/image/en751627.mk
patches/002-add-vmg8825-t50-chboot.patch   ← A/B OS switching (experimental, untested)
scripts/unlock_bootloader.sh   ← wrapper to generate the ATEN password
scripts/apply_and_build.sh     ← applies patches + builds (includes the WSL fix)
```

## License

GPL-2.0-only OR BSD-2-Clause, matching the OpenWrt/kernel DTS files this work derives from.

## Contributing

Pull requests welcome — especially for: native Ethernet driver, WiFi MAC address from the correct EEPROM source, hardware verification of the chboot patch.
