# Changelog

## v0.2.0

* Install the CIX NPU userspace (`cix-npu-umd` / `cix-noe-umd`) into the Buildroot
  **staging** sysroot as well as the target, so out-of-tree NIFs (e.g. the
  `cix_p1_tpu` Elixir library) can cross-link against `-lnoe`/`-laipudrv` and
  `#include` the NOE/AIPU headers at firmware build time.

## v0.1.0

Initial version.

* Linux 6.6.89 (orangepi-xunlong `orange-pi-6.6-cix` @ f41a4f0b), ACPI boot
* UEFI + GRUB 2 (Buildroot arm64-efi) boot chain, kernel inside squashfs
* GPT layout with fixed partition GUIDs, A/B slots (1 GiB each) + ext4 app
  partition
* Nerves KV store in a raw u-boot-env block at LBA 64
* Wired Ethernet (r8169 built-in + rtl_nic firmware), no WiFi/BT
* IEx console on ttyAMA2 (debug UART)
