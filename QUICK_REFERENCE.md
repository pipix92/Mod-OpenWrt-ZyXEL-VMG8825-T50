# Quick Reference - Zyxel VMG8825-T50 OpenWrt Build

## 🎯 One-Page Overview

### Target Configuration
```
Target: en75xx (EcoNet EN75xx)
Subtarget: en751627 (MIPS 1004Kc Big Endian)
Device: Zyxel VMG8825-T50
Architecture: MIPS 1004Kc with DSP
Kernel: Linux 5.15
```

### Key Files
```
target/linux/en75xx/Makefile           - Main target configuration
target/linux/en75xx/Config.in          - Target system config
target/linux/en75xx/en751627/target.mk - Subtarget definition
target/linux/en75xx/dts/*.dts          - Device tree source
target/linux/en75xx/image/Makefile     - Image generation
.config                                 - Build configuration
.github/workflows/build.yml            - CI/CD automation
```

### USB Configuration (Device Tree)
```c
usb2@bfb00000 {           // USB 2.0 EHCI
    status = "okay";       // ✅ ENABLED
    power-domains = <&usb2_power>;
}

usb3@bfb80000 {           // USB 3.0 XHCI
    status = "okay";       // ✅ ENABLED
    power-domains = <&usb3_power>;
}
```

### Essential Packages

**USB Support:**
```
kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb3
```

**WiFi Drivers:**
```
kmod-rtl8187        # Realtek (Alfa AWUS036H)
kmod-rt2800-usb     # Ralink (RT3070, RT5370)
kmod-mt76           # MediaTek (MT7610U, MT7612U)
```

**WiFi Tools:**
```
wpa-supplicant wireless-tools iw iwinfo
```

**WISP/Relay:**
```
relayd luci-proto-relay
```

### Build Commands

**Automated (GitHub Actions):**
```bash
git push origin main  # Triggers automatic build
# Download from: Releases or Actions artifacts
```

**Manual Build:**
```bash
# 1. Clone OpenWrt
git clone https://github.com/openwrt/openwrt.git -b openwrt-23.05
cd openwrt

# 2. Copy config
cp -r /path/to/repo/target/linux/en75xx target/linux/
cp /path/to/repo/.config .config

# 3. Setup feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 4. Build
make defconfig
make download -j$(nproc)
make -j$(nproc) V=s

# 5. Find firmware
ls bin/targets/en75xx/en751627/*.bin
```

### Supported USB WiFi Adapters

| Chipset | Driver | Example Adapters |
|---------|--------|------------------|
| RTL8187 | kmod-rtl8187 | Alfa AWUS036H, TP-Link TL-WN722N v1 |
| RT2800 | kmod-rt2800-usb | Alfa AWUS036NH, RT3070/RT5370 |
| MT76x0 | kmod-mt76x0u | Alfa AWUS036AC (MT7610U) |
| MT76x2 | kmod-mt76x2u | Alfa AWUS036ACM (MT7612U) |

### WISP/Relay Setup

1. Connect USB WiFi adapter
2. Access LuCI: http://192.168.1.1
3. Network → Wireless → Scan
4. Join network to repeat
5. Network → Interfaces → Configure relay

### Troubleshooting

**USB not working:**
```bash
lsusb                    # List USB devices
lsmod | grep usb         # Check USB modules
dmesg | grep -i usb      # Check kernel messages
```

**WiFi adapter not detected:**
```bash
lsmod | grep <driver>    # Check driver loaded
iw list                  # List wireless capabilities
```

**Build fails:**
```bash
make clean               # Clean build
make -j1 V=s            # Verbose single-threaded build
```

### Directory Structure
```
.
├── target/linux/en75xx/
│   ├── Makefile                    # Target config
│   ├── Config.in                   # System config
│   ├── dts/
│   │   └── en7516-vmg8825-t50.dts # Device tree
│   ├── en751627/
│   │   └── target.mk               # Subtarget
│   └── image/
│       └── Makefile                # Image generation
├── .config                         # Build config
├── .github/workflows/
│   └── build.yml                   # CI/CD
├── BUILD_GUIDE.md                  # Full documentation
└── IMPLEMENTATION_SUMMARY.md       # Implementation details
```

### Important Notes

⚠️ **DSL and VoIP not included** - This is a minimal build focused on routing and wireless

✅ **USB 2.0 and 3.0 fully enabled** - With power management

✅ **WISP/Relay ready** - Use USB WiFi to extend networks

✅ **Automated builds** - GitHub Actions handles compilation

### Resources

- [OpenWrt Wiki](https://openwrt.org/)
- [VMG8825-T50 Page](https://openwrt.org/inbox/toh/zyxel/zyxel_vmg8825-t50)
- [Build Guide](BUILD_GUIDE.md)
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md)

---
**Quick Start**: Push to GitHub → Wait for build → Download firmware → Flash router
