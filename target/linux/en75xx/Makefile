#
# Copyright (C) 2024 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

ARCH:=mips
BOARD:=en75xx
BOARDNAME:=EcoNet EN75xx (EN7516 SoC)
FEATURES:=squashfs usb pci gpio
SUBTARGETS:=en751627
CPU_TYPE:=1004kc
CPU_SUBTYPE:=dsp

KERNEL_PATCHVER:=5.15

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += \
	kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb3 \
	kmod-rtl8187 kmod-rt2800-usb kmod-mt76 \
	wpad-basic-mbedtls wireless-tools \
	relayd luci-proto-relay

define Target/Description
	Build firmware images for EcoNet EN75xx SoC devices (EN7516).
	Target device: Zyxel VMG8825-T50 (MIPS 1004Kc Big Endian)
endef

$(eval $(call BuildTarget))
