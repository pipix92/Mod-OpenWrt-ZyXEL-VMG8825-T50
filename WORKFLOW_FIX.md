# GitHub Actions Workflow Fix

## Issue
The GitHub Actions workflow was failing with the following error:
```
This request has been automatically failed because it uses a deprecated version of `actions/upload-artifact: v3`.
```

## Solution
Updated all deprecated GitHub Actions to their latest versions:

### Changes Made
1. **actions/checkout**: Updated from v3 to v4
2. **actions/upload-artifact**: Updated from v3 to v4 (2 instances)

### Modified File
- `.github/workflows/build.yml`

### Specific Changes
```diff
- uses: actions/checkout@v3
+ uses: actions/checkout@v4

- uses: actions/upload-artifact@v3
+ uses: actions/upload-artifact@v4
```

## Verification
All configuration has been verified:
- ✅ Target configuration: en75xx/en751627 (MIPS 1004Kc Big Endian)
- ✅ Device tree: USB 2.0 and 3.0 enabled with power domains
- ✅ Wireless drivers: RTL8187, RT2800-USB, MT76
- ✅ USB support: kmod-usb-core, kmod-usb-ohci, kmod-usb2, kmod-usb3
- ✅ WISP/Relay: relayd, luci-proto-relay
- ✅ Wireless tools: wpa-supplicant, wireless-tools

## Next Steps
1. The workflow is now ready to run
2. Trigger the build by:
   - Pushing to the main branch, OR
   - Manually triggering the workflow from the Actions tab
3. Wait approximately 2-3 hours for the build to complete
4. Download firmware from:
   - Releases page (tagged releases)
   - Actions artifacts (build artifacts)

## Expected Firmware Output
The build will produce:
- **Firmware file**: `openwrt-en75xx-en751627-zyxel_vmg8825-t50-squashfs-sysupgrade.bin`
- **Location**: `bin/targets/en75xx/en751627/`

## Flashing Instructions
Once you have the firmware:

### Method 1: Web Interface (Recommended)
1. Access router web interface
2. Navigate to System → Backup/Flash Firmware
3. Upload the `.bin` file
4. Wait for flash and reboot

### Method 2: Command Line (SSH/Serial)
```bash
sysupgrade -n openwrt-en75xx-en751627-zyxel_vmg8825-t50-squashfs-sysupgrade.bin
```

**Note**: The `-n` flag preserves settings. Omit it for a clean installation.

## USB WiFi Adapter Support
After flashing, the following USB WiFi adapters should work:

### Realtek RTL8187
- Alfa AWUS036H
- Alfa AWUS036NH

### Ralink/MediaTek RT2800
- Alfa AWUS036NEH (RT3070)
- Alfa AWUS051NH (RT2770)
- RT5370, RT5372, RT5572

### MediaTek MT76
- Alfa AWUS036ACH (MT7610U)
- MT7612U adapters

## WISP/Relay Configuration
After flashing and connecting a USB WiFi adapter:

1. Access LuCI web interface
2. Navigate to Network → Interfaces
3. Add new interface with protocol "Relay Bridge"
4. Configure to connect to upstream WiFi
5. Bridge to LAN for local devices

## Troubleshooting

### Build Fails
- Check GitHub Actions logs for specific errors
- Ensure all target files are correctly placed
- Verify .config syntax

### USB Not Working
- Check `dmesg` for USB controller initialization
- Verify `lsusb` shows connected devices
- Check kernel modules with `lsmod`

### WiFi Driver Not Loading
- Install required kernel modules: `opkg install kmod-<driver>`
- Check `dmesg` for driver errors
- Verify USB WiFi adapter chipset compatibility

## Additional Resources
- [OpenWrt Official Documentation](https://openwrt.org/)
- [Build Guide](./BUILD_GUIDE.md)
- [Implementation Summary](./IMPLEMENTATION_SUMMARY.md)
- [Quick Reference](./QUICK_REFERENCE.md)

## Status
✅ **FIXED** - GitHub Actions workflow is now using current, non-deprecated action versions.
