# 📚 Documentation Index - ZyXEL VMG8825-T50 Firmware

## 🎯 Quick Navigation

### For Flashing Firmware via TTL (Serial Console)

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[TTL_FLASH_QUICK_REFERENCE.md](TTL_FLASH_QUICK_REFERENCE.md)** | One-page quick reference | ⭐ **START HERE** - Quick lookup |
| **[FIRMWARE_FLASHING_GUIDE.md](FIRMWARE_FLASHING_GUIDE.md)** | Complete detailed guide | Need full instructions |
| **[build/stock/README.md](build/stock/README.md)** | Firmware binary info | Check firmware details |

### Helper Scripts

| Script | Purpose | Command |
|--------|---------|---------|
| **prepare-flash.sh** | System preparation & checks | `./prepare-flash.sh` |
| **verify-firmware.sh** | Verify firmware integrity | `./verify-firmware.sh` |

### For Building Custom OpenWrt

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[BUILD_GUIDE.md](BUILD_GUIDE.md)** | OpenWrt build system guide | Build custom firmware |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Build quick reference | Quick build commands |
| **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** | Technical implementation | Understand internals |

### Additional Resources

| Resource | Purpose |
|----------|---------|
| **[tools/serial_upgrade.md](tools/serial_upgrade.md)** | Italian TTL flashing guide |
| **[tools/serial_access.md](tools/serial_access.md)** | Serial console access |
| **[tools/password_root.js](tools/password_root.js)** | Password calculator |
| **[tools/password_root.md](tools/password_root.md)** | Password recovery guide |

---

## 🚀 Recommended Workflow

### First Time Users

1. **Read**: [TTL_FLASH_QUICK_REFERENCE.md](TTL_FLASH_QUICK_REFERENCE.md) (5 minutes)
2. **Run**: `./prepare-flash.sh` to check your system
3. **Run**: `./verify-firmware.sh` to verify binaries
4. **Read**: [FIRMWARE_FLASHING_GUIDE.md](FIRMWARE_FLASHING_GUIDE.md) for details
5. **Flash**: Follow the step-by-step instructions

### Experienced Users

1. **Quick Check**: Run `./verify-firmware.sh`
2. **Reference**: Use [TTL_FLASH_QUICK_REFERENCE.md](TTL_FLASH_QUICK_REFERENCE.md)
3. **Flash**: Execute TTL flashing procedure

### Custom Build Users

1. **Setup**: Follow [BUILD_GUIDE.md](BUILD_GUIDE.md)
2. **Configure**: Customize `.config` as needed
3. **Build**: Use GitHub Actions or manual build
4. **Flash**: Use resulting firmware with TTL procedure

---

## 📦 Available Firmware Files

Located in `build/stock/`:

| File | Size | Description | Recommended |
|------|------|-------------|-------------|
| **V550ABOM3C0.bin** | 22MB | Stock V5.50(ABOM.3)C0 | ✅ **YES** |
| V550ABOM6C0.bin | 27MB | Stock V5.50(ABOM.6)C0 | Alternative |
| V550ABOM7C0.bin | 32MB | Stock V5.50(ABOM.7)C0 | Latest |

**Checksums**:
- [SHA256SUMS](build/stock/SHA256SUMS) - SHA256 verification
- [MD5SUMS](build/stock/MD5SUMS) - MD5 verification

---

## 🛠️ Tools & Scripts

### prepare-flash.sh

**Purpose**: Automated system preparation for TTL flashing

**What it does**:
- ✅ Checks operating system
- ✅ Verifies required dependencies (picocom, tftp, etc.)
- ✅ Detects USB-TTL serial ports
- ✅ Validates firmware files
- ✅ Verifies checksums
- ✅ Checks network configuration
- ✅ Provides next steps

**Usage**:
```bash
./prepare-flash.sh
```

### verify-firmware.sh

**Purpose**: Verify firmware binary integrity

**What it does**:
- ✅ Checks firmware file existence
- ✅ Displays file sizes
- ✅ Calculates SHA256 checksums
- ✅ Calculates MD5 checksums
- ✅ Verifies against known good checksums
- ✅ Provides recommendations

**Usage**:
```bash
./verify-firmware.sh
```

---

## 📖 Document Summaries

### TTL_FLASH_QUICK_REFERENCE.md
**Length**: 1 page  
**Reading Time**: 3-5 minutes  
**Content**:
- Hardware pinout diagram
- Network setup commands
- Complete TTL procedure (10 steps)
- Troubleshooting table
- Timeline expectations

**Best for**: Quick lookups during flashing

### FIRMWARE_FLASHING_GUIDE.md
**Length**: Full guide  
**Reading Time**: 15-20 minutes  
**Content**:
- Complete prerequisites
- Detailed hardware setup
- Software installation
- Step-by-step flashing (9 detailed steps)
- Password recovery
- Post-flash configuration
- Extensive troubleshooting
- Safety warnings

**Best for**: First-time users, comprehensive reference

### BUILD_GUIDE.md
**Length**: Full technical guide  
**Reading Time**: 20-30 minutes  
**Content**:
- OpenWrt build system overview
- Hardware specifications
- USB and WiFi driver support
- GitHub Actions automation
- Manual build instructions
- Customization options
- WISP/Relay configuration
- Troubleshooting

**Best for**: Building custom OpenWrt firmware

---

## 🎓 Learning Path

### Beginner: Just Want to Flash

```
1. TTL_FLASH_QUICK_REFERENCE.md (read overview)
2. prepare-flash.sh (run)
3. FIRMWARE_FLASHING_GUIDE.md (read detailed steps)
4. Flash firmware
```

### Intermediate: Want to Understand

```
1. FIRMWARE_FLASHING_GUIDE.md (read all)
2. build/stock/README.md (understand firmware)
3. tools/serial_upgrade.md (additional context)
4. Flash firmware
```

### Advanced: Want to Customize

```
1. BUILD_GUIDE.md (complete read)
2. IMPLEMENTATION_SUMMARY.md (technical details)
3. Modify .config or device tree
4. Build custom firmware
5. Flash custom firmware
```

---

## ⚠️ Important Safety Information

**Before doing anything, understand these critical points**:

### Hardware Safety
- ⚠️ **NEVER** use 5V TTL adapter (use 3.3V only)
- ⚠️ **DO NOT** connect VCC pin (power through router's power supply)
- ⚠️ **ENSURE** stable power supply during flashing
- ⚠️ **VERIFY** proper TX/RX connection (TX → RX, RX → TX)

### Software Safety
- ⚠️ **VERIFY** firmware checksums before flashing
- ⚠️ **BACKUP** current configuration and credentials
- ⚠️ **DO NOT** interrupt flashing process
- ⚠️ **WAIT** for complete boot (can take 2-5 minutes)

### Legal Safety
- ⚠️ Flashing firmware **voids warranty**
- ⚠️ Use at **your own risk**
- ⚠️ We are **not responsible** for damage
- ⚠️ This is **unofficial firmware**

---

## 🆘 Getting Help

### If something goes wrong:

1. **Check documentation**:
   - [FIRMWARE_FLASHING_GUIDE.md](FIRMWARE_FLASHING_GUIDE.md#troubleshooting) - Troubleshooting section
   - [TTL_FLASH_QUICK_REFERENCE.md](TTL_FLASH_QUICK_REFERENCE.md#troubleshooting) - Quick fixes

2. **Search existing issues**:
   - [GitHub Issues](https://github.com/pipix92/Mod-OpenWrt-ZyXEL-VMG8825-T50/issues)

3. **Ask community**:
   - [ilPuntotecnico Forum](https://www.ilpuntotecnico.com/forum/index.php?topic=82576.30)
   - [Hwupgrade Forum](https://www.hwupgrade.it/)

4. **Create new issue**:
   - [New GitHub Issue](https://github.com/pipix92/Mod-OpenWrt-ZyXEL-VMG8825-T50/issues/new)

---

## 📊 Status & Compatibility

| Feature | Status | Notes |
|---------|--------|-------|
| Stock Firmware Binaries | ✅ Available | 3 versions included |
| TTL Flashing | ✅ Tested | Works with 3.3V adapters |
| Checksum Verification | ✅ Included | SHA256 & MD5 |
| Automated Scripts | ✅ Ready | prepare-flash.sh & verify-firmware.sh |
| Documentation | ✅ Complete | Multiple guides available |
| OpenWrt Build System | ✅ Functional | GitHub Actions ready |
| Community Support | ✅ Active | Forums available |

---

## 🎉 Success Stories

Users have successfully flashed firmware to VMG8825-T50 routers using these guides and tools.

**Reported success rate**: High (when following instructions carefully)

**Common success factors**:
- Using proper 3.3V TTL adapter
- Following documentation step-by-step
- Verifying checksums before flashing
- Patient waiting for complete boot
- Stable power supply

---

## 📝 Version History

| Date | Changes |
|------|---------|
| 2024 | Initial repository with stock firmware |
| 2024 | Added OpenWrt build system |
| 2024 | Created comprehensive documentation |
| 2024 | Added helper scripts for automation |
| 2024 | Complete firmware distribution package |

---

## 🤝 Contributing

Contributions welcome! See:
- [README.md](README.md#contributing)
- [BUILD_GUIDE.md](BUILD_GUIDE.md#contributing)

---

**Last Updated**: 2024  
**Maintained By**: Community Contributors  
**License**: GPL v2.0  

---

**Ready to start? Begin with [TTL_FLASH_QUICK_REFERENCE.md](TTL_FLASH_QUICK_REFERENCE.md)!** 🚀
