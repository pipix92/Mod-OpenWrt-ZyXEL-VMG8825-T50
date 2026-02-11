# ZyXEL VMG8825-T50 Firmware Binaries

## 📦 Available Firmware Files

This directory contains **ready-to-flash firmware binaries** for the ZyXEL VMG8825-T50 router.

### Stock Firmware Versions

| File | Size | Version | SHA256 | Recommended |
|------|------|---------|--------|-------------|
| **V550ABOM3C0.bin** | 22MB | V5.50(ABOM.3)C0 | `4ca39d35...` | ✅ **YES** |
| **V550ABOM6C0.bin** | 27MB | V5.50(ABOM.6)C0 | `5cd4daee...` | ⚪ Alternative |
| **V550ABOM7C0.bin** | 32MB | V5.50(ABOM.7)C0 | `af620974...` | ⚪ Latest |

**Recommended**: Start with **V550ABOM3C0.bin** - it's the most tested version for TTL flashing.

## ✅ Checksum Verification

### SHA256 Checksums
```bash
sha256sum -c SHA256SUMS
```

Expected output:
```
V550ABOM3C0.bin: OK
V550ABOM6C0.bin: OK
V550ABOM7C0.bin: OK
```

### MD5 Checksums
```bash
md5sum -c MD5SUMS
```

Full checksums available in:
- `SHA256SUMS` - SHA256 checksums
- `MD5SUMS` - MD5 checksums

## 🚀 Quick Start

### 1. Download Firmware
```bash
# Clone repository
git clone https://github.com/pipix92/Mod-OpenWrt-ZyXEL-VMG8825-T50.git
cd Mod-OpenWrt-ZyXEL-VMG8825-T50/build/stock

# Or download directly
wget https://github.com/pipix92/Mod-OpenWrt-ZyXEL-VMG8825-T50/raw/main/build/stock/V550ABOM3C0.bin
```

### 2. Verify Integrity
```bash
sha256sum V550ABOM3C0.bin
# Should match: 4ca39d35956cb04b0c51c5136c642da15790589b5c829538833b964430da6dcd
```

### 3. Flash via TTL
See **[FIRMWARE_FLASHING_GUIDE.md](../../FIRMWARE_FLASHING_GUIDE.md)** for complete instructions.

**Quick TTL Flashing Steps**:
1. Connect USB-TTL adapter (3.3V) to router
2. Open serial terminal: `picocom -b 115200 /dev/ttyUSB0`
3. Boot router and press any key to enter ZHAL
4. Disable model check: `ZHAL> atdc`
5. Start upgrade: `ZHAL> atur V550ABOM3C0.bin`
6. Transfer file via TFTP: `atftp 192.168.1.1` then `put V550ABOM3C0.bin`
7. Wait for completion and reboot

## 🔐 Default Credentials

### Stock Firmware
- **Web Interface**: http://192.168.1.1
- **Username**: `admin` or `supervisor`
- **Password**: Check router label or calculate from seed

### Password Recovery
If you can't log in:
```bash
# Get seed from bootloader
ZHAL> atse
Seed: XXXXXXXXXXXX

# Calculate password
node ../../tools/password_root.js XXXXXXXXXXXX
```

## 📋 Firmware Version Details

### V5.50(ABOM.3)C0 - RECOMMENDED ✅
- **Size**: 22,049,891 bytes
- **Date**: Stock firmware from ZyXEL
- **Features**: Base firmware, most compatible
- **Best for**: Initial flash, recovery, testing

### V5.50(ABOM.6)C0
- **Size**: 27,262,976 bytes
- **Date**: Updated version
- **Features**: Enhanced features
- **Best for**: Alternative if V3 doesn't work

### V5.50(ABOM.7)C0
- **Size**: 32,505,856 bytes
- **Date**: Latest stock version
- **Features**: Latest updates
- **Best for**: Most recent features

## ⚠️ Important Notes

### Before Flashing
- ✅ **Backup** your configuration
- ✅ **Write down** current credentials
- ✅ **Verify** checksum
- ✅ **Use stable** power supply
- ✅ **Check** USB-TTL voltage (3.3V only!)

### Safety
- ⚠️ **DO NOT** use 5V TTL adapter
- ⚠️ **DO NOT** interrupt flashing process
- ⚠️ **DO NOT** power off during flash
- ⚠️ **DO NOT** disconnect Ethernet during TFTP

### After Flashing
1. Wait for complete boot (2-3 minutes)
2. Log in to web interface
3. Change default password immediately
4. Save configuration to ROM-D
5. Create backup

## 🛠️ Building OpenWrt Firmware

If you want to build custom OpenWrt firmware instead:

1. **Trigger GitHub Actions**:
   - Go to: Repository → Actions
   - Select: "Build OpenWrt Firmware"
   - Click: "Run workflow"
   - Wait: ~2-3 hours

2. **Download Build**:
   - Artifacts: From Actions run
   - Releases: From Releases page

3. **Manual Build**:
   ```bash
   git clone https://github.com/openwrt/openwrt.git -b openwrt-23.05
   cd openwrt
   cp -r /path/to/repo/target/linux/en75xx target/linux/
   cp /path/to/repo/.config .config
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   make defconfig
   make download -j$(nproc)
   make -j$(nproc) V=s
   ```

## 📚 Resources

### Documentation
- **[FIRMWARE_FLASHING_GUIDE.md](../../FIRMWARE_FLASHING_GUIDE.md)** - Complete flashing guide
- **[BUILD_GUIDE.md](../../BUILD_GUIDE.md)** - OpenWrt build instructions
- **[README.md](../../README.md)** - Project overview

### Tools
- **[tools/serial_upgrade.md](../../tools/serial_upgrade.md)** - TTL flashing guide (Italian)
- **[tools/password_root.js](../../tools/password_root.js)** - Password calculator
- **[tools/serial_access.md](../../tools/serial_access.md)** - Serial access guide

### Community
- [OpenWrt Wiki](https://openwrt.org/inbox/toh/zyxel/zyxel_vmg8825-t50)
- [ilPuntotecnico Forum](https://www.ilpuntotecnico.com/forum/index.php?topic=82576.30)
- [Hwupgrade Forum](https://www.hwupgrade.it/)

## 🆘 Troubleshooting

### "File too large" Error
- Use V550ABOM3C0.bin (smallest)
- Try different TFTP client
- Check available memory in ZHAL

### "Model check failed"
- Run `ZHAL> atdc` to disable check
- Verify you're using correct firmware

### "TFTP timeout"
- Check Ethernet cable
- Verify IP: 192.168.1.100 on PC
- Disable firewall
- Try manual TFTP server

### Boot Loop After Flash
- Wait 5+ minutes for first boot
- Try factory reset
- Re-flash via TTL

## ⚖️ Legal & Warranty

- ⚠️ Flashing firmware **voids warranty**
- ⚠️ Use at **your own risk**
- ⚠️ We are **not responsible** for damage
- ⚠️ This is **unofficial firmware**

## 📊 File Information

```
build/stock/
├── V550ABOM3C0.bin      # 22MB - Stock V5.50(ABOM.3)C0
├── V550ABOM6C0.bin      # 27MB - Stock V5.50(ABOM.6)C0
├── V550ABOM7C0.bin      # 32MB - Stock V5.50(ABOM.7)C0
├── V550ABOM3C0.rom      # ROM file
├── SHA256SUMS           # SHA256 checksums
├── MD5SUMS              # MD5 checksums
└── README.md            # This file
```

---

**Status**: ✅ Ready for Flashing  
**Tested**: Yes (V550ABOM3C0.bin recommended)  
**Support**: GitHub Issues or Community Forums  

**Happy Flashing! 🎉**
