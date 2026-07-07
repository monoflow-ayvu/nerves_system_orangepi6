# Changelog

## v0.4.0

* **Display/GPU stack (M2).** `cix-gpu-umd` is now a real Buildroot GL
  provider: libglvnd supplies the linkable `libEGL`/`libGLESv2` (dispatching
  to the `libEGL_cix` ICD at runtime) and the package provides the `libgbm`
  virtual package (mesa `gbm.h` + `gbm.pc` staged against the blob's
  full-featured libgbm). GL/GBM libs get `/usr/lib` symlinks, so no
  `LD_LIBRARY_PATH` is needed for the GPU stack. Adds `weston` (DRM backend,
  desktop + kiosk shells, demo clients) and `kmscube`;
  `XDG_RUNTIME_DIR=/run/xdg` created by `cix-coldplug.sh`.
* **Multimedia.** GStreamer 1.24 (tools + base/good/bad plugins: ALSA, v4l2
  + v4l2codecs, kmssink, waylandsink, GL/GLES-EGL-wayland, mp4/matroska/
  mpegts, RTP/RTSP) and gst1-libav + `ffmpeg`/`ffprobe` (GPL) for
  conversion. `cix-gstreamer` blob plugins enabled (V4L2 M2M VPU decode,
  cixsr super-resolution, fdkaac, kms/va sinks); the blob's private
  GStreamer 1.22 core-lib copies and the X11-only gtk/opengl plugins are no
  longer installed so they can't shadow the system 1.24 libs.
* **Audio.** `alsa-lib` + `alsa-utils` (aplay, amixer, alsamixer, alsactl,
  alsaucm, speaker-test). Kernel SND/SOF-CIX/HDA/USB-audio support was
  already present; DSP firmware + offload codecs ship via `cix-audio-dsp`.
* **Webcams.** libv4l + `v4l2-ctl` (uvcvideo was already in-kernel);
  GStreamer `v4l2src` enabled with probing.
* **WiFi.** rtw88/rtw89 firmware (stock RTL8852BE M.2 module included),
  `wpa_supplicant` (nl80211, AP mode, WPA3, WPS, EAP) for
  `vintage_net_wifi`, `iw`, `wireless-regdb`.
* **Bluetooth.** Realtek 88xx BT firmware for `btusb` + BlueZ
  (`bluetoothctl`, monitor, tools). `bluetoothd` requires starting
  `dbus-daemon --system` from the application.

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
