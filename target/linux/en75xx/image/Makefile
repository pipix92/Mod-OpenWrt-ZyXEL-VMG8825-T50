#
# Copyright (C) 2024 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

KERNEL_LOADADDR := 0x80001000

define Device/Default
	PROFILES := Default
	KERNEL_NAME := vmlinux
	KERNEL := kernel-bin | append-dtb | lzma | uImage lzma
	KERNEL_INITRAMFS := kernel-bin | append-dtb | lzma | uImage lzma
	DEVICE_DTS_DIR := ../dts
	IMAGES := sysupgrade.bin
	IMAGE/sysupgrade.bin := append-kernel | pad-to 64k | append-rootfs | pad-rootfs | check-size | append-metadata
endef

define Device/zyxel_vmg8825-t50
	$(call Device/Default)
	DEVICE_VENDOR := Zyxel
	DEVICE_MODEL := VMG8825-T50
	DEVICE_DTS := en7516-vmg8825-t50
	DEVICE_PACKAGES := kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb3 \
		kmod-rtl8187 kmod-rt2800-usb kmod-mt76 \
		wpad-basic-mbedtls wireless-tools \
		relayd luci-proto-relay
	IMAGE_SIZE := 16384k
endef
TARGET_DEVICES += zyxel_vmg8825-t50

$(eval $(call BuildImage))
