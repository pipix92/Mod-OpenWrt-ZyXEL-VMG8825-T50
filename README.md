<!-- PROJECT BUNNER-->
<div align="center">
  <img src="https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg" alt="Awesome Badge"/>
  <img src="https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99" alt="Star Badge"/>
  <img src="https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg" alt="Ask Badge"/>
  <br>
</div>  

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://service-provider.zyxel.com/sites/default/files/styles/large/public/2020-09/img_vmg8825-t50k_p.png?itok=ZHXKESVr" alt="Logo" width="280" height="280">
  </a>

  <h3 align="center">OpenWrt for ZyXEL VMG8825-T50/K</h3>

  <p align="center">
    Porting OpenWrt
    The original firmwares are all based on OpenWrt Attitude Adjustment, so the chance of success is very high.
    In this period I am blocked from university studies, as soon as I finish, I immediately start working on it. If anyone wants to start working on it in between, I'm grateful. 
    Try to put more sources, firmware and raw, on this github. I have an idea of how to proceed, the more information we have the better.
    <br />
    <a href="https://www.ilpuntotecnico.com/forum/index.php?topic=82576.30"><strong>ilPuntotecnico</strong></a>
    <a href="https://www.hwupgrade.it/forum/showpost.php?p=47308598&postcount=16"><strong>Hwupgrade</strong></a>
    <a href="https://th0mas.nl/2020/03/26/getting-root-on-a-zyxel-vmg8825-t50-router/"><strong>Th0mas</strong></a>
    <a href="https://www.zyxel.com/support/download_landing/product/vmg8825_t50k_14.shtml?c=gb&l=en&pid=20180720160007&tab=Firmware&pname=VMG8825-T50K"><strong>Explore firmware official»</strong></a>
    <br />
    <br />
    <a href="https://openwrt.org/inbox/toh/zyxel/zyxel_vmg8825-t50">OpenWrt</a>
    ·
    <a href="https://www.zyxel.com/products_services/Dual-Band-Wireless-AC-N-VDSL2-Combo-WAN-Gigabit-IAD-VMG8825-T50K/">Zyxel</a>
  </p>
</div>
 
# 🔥 Ready-to-Flash Firmware Binaries

## ⚡ Quick Download

**Pre-built firmware binaries are available in [`build/stock/`](build/stock/)**

| Firmware | Size | Version | Download | Status |
|----------|------|---------|----------|--------|
| **V550ABOM3C0.bin** | 22MB | V5.50(ABOM.3)C0 | [Download](build/stock/V550ABOM3C0.bin) | ✅ **RECOMMENDED** |
| **V550ABOM6C0.bin** | 27MB | V5.50(ABOM.6)C0 | [Download](build/stock/V550ABOM6C0.bin) | ⚪ Alternative |
| **V550ABOM7C0.bin** | 32MB | V5.50(ABOM.7)C0 | [Download](build/stock/V550ABOM7C0.bin) | ⚪ Latest |

### 📋 Checksums
- **SHA256**: See [SHA256SUMS](build/stock/SHA256SUMS)
- **MD5**: See [MD5SUMS](build/stock/MD5SUMS)

### 🚀 How to Flash via TTL

**🎯 ONE-COMMAND PREPARATION**:
```bash
./prepare-flash.sh    # Automated system check & preparation
./verify-firmware.sh  # Verify firmware integrity
```

**Complete guide**: [FIRMWARE_FLASHING_GUIDE.md](FIRMWARE_FLASHING_GUIDE.md) | **Quick reference**: [TTL_FLASH_QUICK_REFERENCE.md](TTL_FLASH_QUICK_REFERENCE.md)

**Quick steps**:
1. Connect USB-TTL (3.3V) to router serial port
2. Open terminal: `picocom -b 115200 /dev/ttyUSB0`
3. Enter bootloader: Press any key when "Hit any key to stop autoboot" appears
4. Disable model check: `ZHAL> atdc`
5. Start upgrade: `ZHAL> atur V550ABOM3C0.bin`
6. Transfer via TFTP: `atftp 192.168.1.1` → `put V550ABOM3C0.bin`
7. Wait for completion and reboot

**⚠️ IMPORTANT**: Use 3.3V TTL adapter only (NOT 5V)!

---

# Firmware
```diff
+ VMG8825-T50K_5.50(ABOM.3) -> ftp://ftp.zyxel.com/VMG8825-T50K/firmware/VMG8825-T50K_5.50(ABOM.3)C0.zip
```

# TODO FOR INIT
```diff
- N/A
+ DONE
! IN PROGRESS
# WAITING
@@ ALL COMPLETED@@
```

```diff
+ add kernel main:last
+ add source ZyXEL-VMG8825-T50
+ add source OpenWrt
+ list firmwares ZyXEL-VMG8825-T50
! hack json automate with node.js
! script auto build stock 
# patch all ZyXEL-VMG8825-T50 on Openwrt
# script auto build openwrt
# qemu code generator
```
