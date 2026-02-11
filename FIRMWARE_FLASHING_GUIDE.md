# 🔥 Firmware Flashing Guide for ZyXEL VMG8825-T50 via TTL

## ⚠️ IMPORTANT - READ BEFORE PROCEEDING

**DANGER**: Flashing firmware can brick your device if done incorrectly!

- ✅ **Backup**: Save your current configuration and credentials
- ✅ **Power**: Ensure stable power supply during the entire process
- ✅ **Serial**: Use a proper USB-to-TTL adapter (3.3V ONLY, NOT 5V!)
- ⚠️ **Risk**: You accept all responsibility for any damage

## 📦 Available Firmware Binaries

This repository includes **pre-built firmware binaries** ready for TTL flashing:

### Stock Firmware Versions

Located in `build/stock/`:

| Firmware File | Size | Version | Description |
|--------------|------|---------|-------------|
| **V550ABOM3C0.bin** | 22MB | V5.50(ABOM.3)C0 | Stock firmware - Recommended for TTL flashing |
| **V550ABOM6C0.bin** | 27MB | V5.50(ABOM.6)C0 | Stock firmware - Alternative version |
| **V550ABOM7C0.bin** | 32MB | V5.50(ABOM.7)C0 | Stock firmware - Latest version |

### OpenWrt Custom Firmware

Custom OpenWrt firmware can be built using GitHub Actions:
- Navigate to: **Actions** → **Build OpenWrt Firmware**
- Click: **Run workflow**
- Wait: ~2-3 hours for build completion
- Download: From **Releases** or **Artifacts**

## 🛠️ Hardware Requirements

### USB-to-TTL Serial Adapter
- **Voltage**: 3.3V (NOT 5V - will damage device!)
- **Chipset**: CP2102, FT232, CH340, or similar
- **Connector**: 4-pin: GND, TX, RX, VCC (VCC not needed)

### Serial Connection Pinout

```
VMG8825-T50 Serial Header (J4):
┌─────────────────┐
│  1  2  3  4     │  1 = VCC (3.3V) - DO NOT CONNECT
│  •  •  •  •     │  2 = TX (to RX on adapter)
└─────────────────┘  3 = RX (to TX on adapter)
                     4 = GND (to GND on adapter)
```

**Connection Mapping**:
- Router TX (Pin 2) → USB-TTL RX
- Router RX (Pin 3) → USB-TTL TX
- Router GND (Pin 4) → USB-TTL GND
- **DO NOT CONNECT VCC**

## 💻 Software Requirements

### Linux/macOS
```bash
# Install serial terminal (choose one)
sudo apt install picocom           # Debian/Ubuntu
brew install picocom               # macOS

# Install TFTP client
sudo apt install atftp             # Debian/Ubuntu
brew install atftp                 # macOS
```

### Windows
- **Serial Terminal**: PuTTY or TeraTerm
- **TFTP Client**: Tftpd64 (includes both client and server)

## 📋 Step-by-Step Flashing Procedure

### Step 1: Prepare Your Computer

1. **Download firmware binary**:
```bash
# Clone this repository if not already done
git clone https://github.com/pipix92/Mod-OpenWrt-ZyXEL-VMG8825-T50.git
cd Mod-OpenWrt-ZyXEL-VMG8825-T50

# Or download directly
wget https://github.com/pipix92/Mod-OpenWrt-ZyXEL-VMG8825-T50/raw/main/build/stock/V550ABOM3C0.bin
```

2. **Verify checksum** (optional but recommended):
```bash
sha256sum build/stock/V550ABOM3C0.bin
```

3. **Set up network**:
- Configure your Ethernet adapter with static IP: `192.168.1.100`
- Netmask: `255.255.255.0`
- Gateway: `192.168.1.1`

### Step 2: Connect Serial Cable

1. **Connect USB-TTL adapter** to router's serial header (remember: GND, TX→RX, RX→TX)
2. **Plug USB adapter** into your computer
3. **Identify serial port**:

```bash
# Linux
ls /dev/ttyUSB*    # Usually /dev/ttyUSB0

# macOS
ls /dev/tty.usb*   # e.g., /dev/tty.usbserial-*

# Windows
# Use Device Manager → Ports (COM & LPT)
```

### Step 3: Open Serial Terminal

**Linux/macOS**:
```bash
sudo picocom -b 115200 /dev/ttyUSB0
```

**Windows PuTTY**:
- Connection Type: Serial
- Serial Line: COM3 (or your port)
- Speed: 115200
- Data bits: 8
- Stop bits: 1
- Parity: None
- Flow control: None

### Step 4: Enter Bootloader (ZHAL)

1. **Connect Ethernet cable** between router and computer
2. **Power on the router**
3. **Watch serial output** - you'll see boot messages
4. **Press any key** when you see: `Hit any key to stop autoboot: 5`

You should now see the `ZHAL>` prompt:
```
ZHAL> 
```

### Step 5: Disable Model Check

This allows flashing different firmware versions:

```
ZHAL> atdc
Model ID check: disabled
ZHAL> 
```

### Step 6: Start TFTP Transfer

1. **In ZHAL prompt**, start firmware upgrade:
```
ZHAL> atur V550ABOM3C0.bin
Upgrade to rootfs partition 1
TFTP server is started, put your file 'V550ABOM3C0.bin' to server (IP is 192.168.1.1)
```

The router is now waiting for the firmware file via TFTP.

2. **Open a NEW terminal** (keep serial terminal visible) and send the firmware:

**Linux/macOS**:
```bash
cd Mod-OpenWrt-ZyXEL-VMG8825-T50
atftp 192.168.1.1
tftp> binary
tftp> put build/stock/V550ABOM3C0.bin
tftp> quit
```

**Windows (Tftpd64)**:
- Server: 192.168.1.1
- Port: 69
- File: V550ABOM3C0.bin
- Click "Put"

### Step 7: Wait for Flash Process

You'll see progress in the serial terminal:

```
TFTP server is started, put your file 'V550ABOM3C0.bin' to server (IP is 192.168.1.1).
......................................................................................
Total 23049891 (0x15FB6A3) bytes received

File download to memory address 0x80020000, length is 23049891
Ignore checking model ID!

Please be patient, start to upgrade RAS!

............................................................................................
Update boot flag to 1
...Auto reboot after 2 seconds
```

**DO NOT INTERRUPT** - Let the process complete!

### Step 8: First Boot

After reboot, the firmware will boot up. This may take 2-3 minutes.

You should see boot logs in the serial terminal, ending with a login prompt:

```
VMG8825-T50K login: 
```

Default credentials (stock firmware):
- **Username**: `admin` or `supervisor`
- **Password**: Check label on router or use password generator (see below)

## 🔑 Password Recovery

If you can't log in with default credentials, you can calculate the password:

1. **Get the seed** from ZHAL bootloader:
```
ZHAL> atse
Seed: XXXXXXXXXXXX
```

2. **Use the password generator script**:
```bash
# See tools/password_root.js or tools/password_root.md
node tools/password_root.js XXXXXXXXXXXX
```

## 🚀 Post-Flash Configuration

### Access Web Interface

1. **Connect Ethernet** to router LAN port
2. **Configure PC** with static IP: 192.168.1.100/24
3. **Open browser**: http://192.168.1.1
4. **Login** with credentials

### First Steps

1. **Backup configuration** immediately
2. **Change default password**
3. **Update network settings** as needed
4. **Save to ROM-D** to preserve settings after factory reset

### Flashing OpenWrt (After Stock Flash)

Once stock firmware is running, you can upgrade to OpenWrt:

1. **Build or download OpenWrt** firmware (from GitHub Actions)
2. **Upload via web interface**: System → Firmware Upgrade
3. **Or use sysupgrade** via SSH:
```bash
sysupgrade -v openwrt-en75xx-en751627-zyxel_vmg8825-t50-squashfs-sysupgrade.bin
```

## 🐛 Troubleshooting

### Serial Connection Issues

**No output on serial terminal**:
- Check cable connections (TX↔RX reversed?)
- Verify 115200 baud rate
- Try different serial port
- Ensure 3.3V logic level

**Garbage characters**:
- Wrong baud rate (should be 115200)
- Wrong parity settings (should be 8N1)

### TFTP Transfer Issues

**Connection refused or timeout**:
- Check Ethernet cable connection
- Verify IP address: 192.168.1.100 on PC
- Disable firewall temporarily
- Try different TFTP client

**Transfer starts but fails**:
- Check firmware file integrity
- Ensure stable power supply
- Try smaller firmware file first (V550ABOM3C0.bin)

### Boot Issues After Flash

**Router doesn't boot**:
- Wait longer (first boot can take 5+ minutes)
- Try factory reset via reset button
- Re-flash firmware via TTL

**Can't access web interface**:
- Check IP address (192.168.1.1)
- Check browser (try different one)
- Check credentials (use password calculator)

## 📚 Additional Resources

### Tools in This Repository

- `tools/serial_upgrade.md` - Italian flashing guide
- `tools/password_root.js` - Password generator
- `tools/password_root.md` - Password calculation guide
- `tools/serial_access.md` - Serial access instructions

### External Resources

- [OpenWrt Wiki - VMG8825-T50](https://openwrt.org/inbox/toh/zyxel/zyxel_vmg8825-t50)
- [Getting Root on VMG8825-T50](https://th0mas.nl/2020/03/26/getting-root-on-a-zyxel-vmg8825-t50-router/)
- [ZyXEL Official Firmware](https://www.zyxel.com/support/download_landing/product/vmg8825_t50k_14.shtml)

## ⚖️ Legal & Disclaimer

- Flashing firmware **voids warranty**
- Use at **your own risk**
- We are **not responsible** for any damage
- This is **unofficial firmware** - not supported by ZyXEL
- Ensure you have **legal right** to modify your device

## 🤝 Support & Community

- **GitHub Issues**: Report problems or ask questions
- **Pull Requests**: Contribute improvements
- **Community Forums**: [ilPuntotecnico](https://www.ilpuntotecnico.com/forum/index.php?topic=82576.30), [Hwupgrade](https://www.hwupgrade.it/)

---

**Status**: ✅ Ready to Flash  
**Last Updated**: 2024  
**Success Rate**: High (when following instructions carefully)

**Good luck with your flash! 🎉**
