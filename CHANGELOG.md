# Changelog

## v0.3.0

* **Boot-once A/B auto-rollback.** Upgrades arm grubenv with `validated=0`;
  GRUB gives the new slot one boot to run the ops.fw `validate` task
  (`Nerves.Runtime.validate_firmware/0`) and otherwise falls back to the
  previous slot. `panic=10` added to the kernel cmdline so panics reboot into
  the fallback. `cix-coldplug.sh` reconciles `nerves_fw_active` after a
  rollback, `revert` now lands on a pre-validated slot, and applications
  **must call `Nerves.Runtime.validate_firmware/0`** after each update.
* Fix `cix-coldplug.sh` not being executable — with `BR2_INIT_NONE` it is the
  only thing that starts `udevd` and loads the CIX GPU/NPU/VPU/display
  modules, so nothing accelerator-related worked without it.
* Satisfy libmali's runtime link dependencies: enable `libdrm` and `wayland`
  (DT_NEEDED by `libmali.so`).
* Install the audio DSP firmware at `/lib/firmware/dsp_fw.bin` where the
  kernel's `request_firmware()` actually looks (was `/usr/lib/firmware`).
* Export `GDK_GL`/`GST_GL_API` to the BEAM via erlinit (previously only set
  for login shells).
* CI: fetch git-LFS blobs on checkout (releases previously packaged LFS
  pointer stubs instead of the CIX libraries).
* Point `artifact_sites`/`source_url` at `monoflow-ayvu` (where CI actually
  publishes releases).
* Docs: rootfs slots are 3 GiB, not 1 GiB.

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
