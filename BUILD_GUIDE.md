# OpenWrt Build System for Zyxel VMG8825-T50

This repository provides a complete OpenWrt build system configuration for the **Zyxel VMG8825-T50** router, featuring the EcoNet EN7516 SoC (MIPS 1004Kc architecture).

## 🎯 Features

### Hardware Support
- **Target**: EcoNet EN75xx
- **Subtarget**: EN751627 (MIPS 1004Kc Big Endian)
- **SoC**: EN7516
- **Architecture**: MIPS 1004Kc with DSP
- **Memory**: 256MB RAM
- **Storage**: 16MB Flash

### USB Support
- ✅ USB 2.0 (EHCI/OHCI)
- ✅ USB 3.0 (XHCI)
- ✅ Power management for both USB ports
- ✅ Full USB device support

### Wireless Features
- **USB WiFi Chipsets**:
  - Realtek RTL8187
  - Ralink/MediaTek RT2800-USB
  - MediaTek MT76 (MT76x0u, MT76x2u, MT7603)
  
- **Wireless Tools**:
  - wpa-supplicant
  - wireless-tools
  - iw / iwinfo

### WISP/Relay Mode
- ✅ `relayd` - Relay daemon for extending network
- ✅ `luci-proto-relay` - LuCI interface for relay configuration
- Perfect for using USB WiFi adapters to extend/repeat wireless networks

## 📁 Project Structure

```
.
├── target/
│   └── linux/
│       └── en75xx/                    # Target platform
│           ├── Makefile               # Main target makefile
│           ├── Config.in              # Target configuration
│           ├── dts/                   # Device tree sources
│           │   └── en7516-vmg8825-t50.dts
│           ├── en751627/              # Subtarget
│           │   └── target.mk
│           └── image/                 # Image generation
│               └── Makefile
├── .config                            # OpenWrt build configuration
└── .github/
    └── workflows/
        └── build.yml                  # Automated build workflow
```

## 🚀 Quick Start

### Automated Build (GitHub Actions)

The repository includes a GitHub Actions workflow that automatically builds the firmware:

1. **Trigger Build**: Push to main/master branch or manually trigger the workflow
2. **Wait**: Build takes approximately 2-3 hours
3. **Download**: Firmware artifacts are uploaded as release assets

### Manual Build

#### Prerequisites

Install build dependencies on Ubuntu 22.04:

```bash
sudo apt-get update
sudo apt-get install build-essential clang flex bison g++ gawk \
  gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
  python3-distutils rsync unzip zlib1g-dev file wget qemu-utils \
  libelf-dev device-tree-compiler python3-setuptools python3-yaml \
  swig antlr3 gperf autoconf automake libtool ccache ecj fastjar \
  java-propose-classpath libncursesw5-dev xsltproc
```

#### Build Steps

1. **Clone OpenWrt source**:
```bash
git clone https://github.com/openwrt/openwrt.git -b openwrt-23.05
cd openwrt
```

2. **Copy custom configuration**:
```bash
# Copy target configuration
cp -r /path/to/this/repo/target/linux/en75xx target/linux/

# Copy build config
cp /path/to/this/repo/.config .config
```

3. **Update and install feeds**:
```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

4. **Configure and build**:
```bash
make defconfig
make download -j$(nproc)
make -j$(nproc) V=s
```

5. **Find firmware**:
```bash
ls -lh bin/targets/en75xx/en751627/
```

## 📦 Included Packages

### Core System
- LuCI web interface with SSL
- Firewall (iptables/ip6tables)
- dnsmasq (DNS/DHCP server)
- PPPoE support

### USB Support
- `kmod-usb-core` - Core USB support
- `kmod-usb-ohci` - USB 1.1 OHCI support
- `kmod-usb2` - USB 2.0 EHCI support
- `kmod-usb3` - USB 3.0 XHCI support

### WiFi Drivers (USB)
- `kmod-rtl8187` - Realtek RTL8187 (Alfa AWUS036H, etc.)
- `kmod-rt2800-usb` - Ralink RT2800 USB (RT3070, RT5370, etc.)
- `kmod-mt76` - MediaTek MT76x0u, MT76x2u (Alfa AWUS036ACM, etc.)

### Wireless Tools
- `wpad-basic-mbedtls` - WiFi Protected Access daemon
- `wpa-supplicant` - WPA client
- `wireless-tools` - Wireless configuration tools
- `iw` / `iwinfo` - Modern wireless tools

### WISP/Relay
- `relayd` - Relay daemon
- `luci-proto-relay` - LuCI relay protocol interface

## 🔧 Configuration

### Target Configuration

The build is configured for:
- **Target System**: EcoNet EN75xx (EN7516 SoC)
- **Subtarget**: EN751627 (MIPS 1004Kc Big Endian)
- **Target Profile**: Zyxel VMG8825-T50

### Device Tree

The device tree (`target/linux/en75xx/dts/en7516-vmg8825-t50.dts`) includes:
- USB 2.0 controller with power management
- USB 3.0 controller with power management
- GPIO LEDs (power, internet, wifi, usb)
- GPIO buttons (reset, wps)
- SPI flash partitioning
- Ethernet controller
- Serial console

### USB Configuration

USB ports are fully configured in the device tree with:
- Power domain management
- Port status set to "okay"
- Proper interrupt configuration
- Compatible driver strings

## 🌐 WISP/Relay Mode Setup

To use your USB WiFi adapter to repeat/extend a wireless network:

1. **Connect USB WiFi adapter** to the router
2. **Log into LuCI** web interface (usually http://192.168.1.1)
3. **Navigate to Network → Wireless**
4. **Scan for networks** with your USB adapter
5. **Join the network** you want to repeat
6. **Configure relay protocol** in Network → Interfaces
7. **Enable relayd** to bridge the connections

## 🔍 Supported USB WiFi Adapters

### Confirmed Compatible Chipsets

#### Realtek RTL8187
- Alfa AWUS036H
- TP-Link TL-WN722N v1

#### Ralink RT2800
- Alfa AWUS036NH
- TP-Link TL-WN722N v2/v3
- Ralink RT3070/RT5370/RT5572

#### MediaTek MT76
- Alfa AWUS036ACM (MT7612U)
- Alfa AWUS036AC (MT7610U)
- TP-Link Archer T2U/T3U

## 📖 EcoNet EN7516 Reference

This build system references the EcoNet-Linux project for EN7516 chipset support:
- Kernel patches are based on EcoNet SDK
- Device tree structure follows EcoNet conventions
- USB and peripheral drivers use EcoNet-compatible configurations

**Note**: DSL and VoIP functionality are not included in this minimal build. Focus is on routing, wireless, and USB functionality.

## 🛠️ Customization

### Adding More Packages

Edit `.config` and add package lines:
```
CONFIG_PACKAGE_your-package=y
```

Then rebuild:
```bash
make defconfig
make -j$(nproc) V=s
```

### Modifying Device Tree

Edit `target/linux/en75xx/dts/en7516-vmg8825-t50.dts` to:
- Change GPIO assignments
- Modify USB configuration
- Adjust memory/flash partitions
- Add/remove peripherals

### Kernel Configuration

The build uses Linux kernel 5.15 with MIPS-specific options configured for 1004Kc processor.

## 📝 GitHub Actions Workflow

The `.github/workflows/build.yml` workflow:

1. **Environment Setup**: Installs all required build tools
2. **Clone OpenWrt**: Gets the latest OpenWrt 23.05 source
3. **Apply Configuration**: Copies target and config files
4. **Apply Patches**: Applies EN7516-specific patches
5. **Build Firmware**: Compiles with multiple threads
6. **Upload Artifacts**: Saves firmware files
7. **Create Release**: Generates release with firmware files

### Triggering Builds

- **Automatic**: Push to main/master branch
- **Manual**: Use "Run workflow" in GitHub Actions tab
- **Pull Request**: Automatic build on PR creation

## 🐛 Troubleshooting

### Build Fails

1. Check disk space: `df -h`
2. Clean and retry: `make clean && make -j1 V=s`
3. Check log files in `logs/` directory

### USB Not Working

1. Verify device tree USB configuration
2. Check kernel modules: `lsmod | grep usb`
3. Check USB devices: `lsusb`
4. Check power management: `cat /sys/kernel/debug/usb/devices`

### WiFi Adapter Not Detected

1. Verify chipset compatibility
2. Check if driver module is loaded: `lsmod | grep <driver>`
3. Try manual module load: `insmod /lib/modules/.../kmod-xxx.ko`
4. Check kernel messages: `dmesg | grep -i usb`

## 📄 License

This project is licensed under the GNU General Public License v2.0 - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request

## 📚 Resources

- [OpenWrt Project](https://openwrt.org/)
- [OpenWrt Wiki - Zyxel VMG8825-T50](https://openwrt.org/inbox/toh/zyxel/zyxel_vmg8825-t50)
- [EcoNet EN7516 SoC](https://www.econetsoc.com/)
- [MIPS Architecture](https://www.mips.com/)

## ⚠️ Disclaimer

This is an unofficial OpenWrt build. Use at your own risk. Always backup your original firmware before flashing.

## 🙏 Acknowledgments

- OpenWrt community
- EcoNet-Linux project
- Zyxel VMG8825-T50 community contributors
- Original firmware analysis contributors

---

**Status**: ✅ Functional Build System  
**Last Updated**: 2024  
**Maintained by**: Community Contributors
