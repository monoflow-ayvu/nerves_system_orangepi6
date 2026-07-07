# Orange Pi 6 — Nerves System

Custom [Nerves](https://nerves-project.org/) system for the
[Orange Pi 6](http://www.orangepi.org/) (CIX P1 / CD8180 "sky1", 12-core ARM64).

Also boots the **Orange Pi 6 Plus** unchanged: both boards share the SoC, the
kernel and the boot mechanism, and with ACPI boot the board-specific hardware
description comes from each board's own on-board UEFI firmware — not from this
image. Declare both targets in your app:
`targets: [:orangepi6, :orangepi6plus]`.

| Feature        | Description                                              |
| -------------- | -------------------------------------------------------- |
| CPU            | CIX P1 (4×A720 + 4×A720 + 4×A520, ARMv9.2)               |
| Memory         | up to 64 GB LPDDR5                                       |
| Storage        | microSD and M.2 NVMe (same image; may coexist), eMMC     |
| Linux kernel   | 6.6.89 (orangepi-xunlong `orange-pi-6.6-cix`, ACPI boot) |
| IEx terminal   | debug UART `ttyAMA2`, 115200 8N1                         |
| Ethernet       | yes (in-tree `r8169`/`macb`/`igb`, no firmware needed)   |
| WiFi           | yes (rtw88/rtw89 firmware for the stock RTL8852BE M.2 module; wpa_supplicant/iw ready for `vintage_net_wifi`) |
| Bluetooth      | yes (`btusb` + Realtek firmware, BlueZ `bluetoothctl`; start `dbus-daemon` + `bluetoothd` from your app) |
| Display / GPU  | weston (DRM backend, desktop + kiosk shells) on the proprietary Mali G720 stack (libglvnd → libEGL_cix), `kmscube` test |
| Multimedia     | GStreamer 1.24 (+ CIX V4L2 M2M VPU plugins, kmssink/waylandsink/GL), `ffmpeg`/`ffprobe` CLI |
| Audio          | ALSA (`alsa-lib`/`alsa-utils`), CIX audio DSP firmware + offload codecs, USB/HDMI audio |

## Boot architecture

The CIX P1 boots PBL → SCP → TF-A → **EDK2 UEFI entirely from on-board SPI
NOR flash** — the SD image contains no bootloader firmware at all. The UEFI
firmware loads `\EFI\BOOT\BOOTAA64.EFI` (GRUB 2, built by Buildroot) from the
ESP. GRUB reads `/EFI/BOOT/grubenv` to select the A/B slot and loads the
kernel from *inside* the slot's squashfs (`/boot/Image`) via its builtin
`squash4` module. The kernel boots with **ACPI** (`acpi=force`) — no device
tree, no initrd.

```
GPT disk layout (fixed partition GUIDs, so root=PARTUUID=... is stable):
  LBA 64      raw u-boot-env block (Nerves.Runtime KV store, no U-Boot involved)
  p1  boot    FAT ESP, 32 MiB: BOOTAA64.EFI, grub.cfg, grubenv
  p2  rootfs.a  squashfs, 3 GiB (kernel inside at /boot/Image)
  p3  rootfs.b  squashfs, 3 GiB
  p4  app     ext4, expands to fill the disk, mounted at /root
```

A/B updates: fwup writes the new rootfs, then flips `nerves_fw_active` in
the uboot-env block and the `boot` variable in grubenv (written last, so an
aborted update never points GRUB at a half-written slot). On-device
revert/validate/status live in `/usr/share/fwup/ops.fw`.

**Boot-once auto-rollback**: an upgrade arms grubenv with `validated=0`.
The new slot gets exactly one boot to call
`Nerves.Runtime.validate_firmware/0`; if the device reboots without
validating (kernel panic — `panic=10` on the cmdline — erlinit reboot,
watchdog, power cycle), GRUB falls back to the previous slot and
`cix-coldplug.sh` re-aligns `nerves_fw_active` in the Nerves KV store with
the slot that actually booted. **Your application must call
`Nerves.Runtime.validate_firmware/0` once it considers itself healthy**
(e.g. after NervesHub connects or your own checks pass), or every firmware
update will be rolled back on the next reboot. Fresh installs (`complete`)
and manual `revert`s land on a pre-validated slot and are not subject to
rollback.

## Building

The system builds via the Docker build runner (`Dockerfile` in this repo), so
it works on non-FHS hosts like NixOS:

```sh
mix deps.get
mix compile    # builds the whole Buildroot system inside the container
```

Note: your **host** Erlang/OTP major version must match the target's (OTP 28,
pinned via `BR2_PACKAGE_ERLANG_28=y`) when building Nerves *applications*
against this system. `shell.nix` provides a matching host environment.

## Using

In your Nerves project's `mix.exs`:

```elixir
{:nerves_system_orangepi6, path: "../nerves_system_orangepi6", runtime: false, targets: :orangepi6}
```

Then `MIX_TARGET=orangepi6 mix firmware && mix firmware.burn`.

Serial console: 3-pin debug UART header, 115200 8N1, 3.3 V (do not connect 5 V).

## Multimedia, display, audio, WiFi/BT

- **Display / GPU**: `weston` (DRM backend) renders through the proprietary
  Mali stack — apps link the neutral `libEGL`/`libGLESv2` (libglvnd), which
  dispatches to `libEGL_cix`/`libmali` via
  `/usr/share/glvnd/egl_vendor.d/40_cix.json`. `XDG_RUNTIME_DIR=/run/xdg` is
  pre-set; start weston from your app, e.g.
  `System.cmd("weston", ["--shell=kiosk-shell.so"])`. `kmscube` and the
  `weston-simple-egl` demo clients are included as GPU sanity tests.
- **Video**: GStreamer 1.24 with the CIX plugins in
  `/usr/share/cix/lib/gstreamer-1.0` (on `GST_PLUGIN_PATH_1_0`): V4L2 M2M VPU
  decode (`amvx`), `kmssink`, `waylandsink`, GL upload. `gst-launch-1.0` /
  `gst-inspect-1.0` are installed; `ffmpeg`/`ffprobe` handle offline
  conversion (software codecs via gst1-libav/ffmpeg as fallback).
- **Webcams**: UVC (`uvcvideo`, auto-loaded) plus `v4l2-ctl`/libv4l;
  capture with GStreamer `v4l2src` (MJPEG decode via jpegdec, mics via
  `snd-usb-audio`). MIPI-CSI sensor drivers (IMX219/OV5640/…) are also
  enabled as modules.
- **Audio**: ALSA (`aplay`, `amixer`, `alsamixer`, `speaker-test`, UCM). The
  CIX audio DSP firmware (`/lib/firmware/dsp_fw.bin`) and offload codecs ship
  in the image; USB and HDMI/DP audio also work (`snd-usb-audio`, HDA).
- **WiFi**: the stock M.2 module (RTL8852BE) uses `rtw89_8852be`
  (auto-loaded via udev) with firmware included; rtw88-family modules are
  also covered. Use [`vintage_net_wifi`](https://hex.pm/packages/vintage_net_wifi)
  — `wpa_supplicant` (nl80211, AP mode, WPA3), `iw` and the regulatory db are
  in the image.
- **Bluetooth**: RTL8852BE BT enumerates over USB (`btusb` + Realtek
  firmware). BlueZ is included (`bluetoothctl`, `hciconfig`); `bluetoothd`
  needs D-Bus, so start `dbus-daemon --system` then `bluetoothd` from your
  app (or use an HCI-level Elixir stack).

## Bring-up fallbacks

- **UEFI doesn't launch our GRUB**: check Secure Boot is disabled in the UEFI
  setup menu. If the Buildroot GRUB still doesn't start, replace
  `BOOTAA64.EFI` on the ESP with the vendor blob
  (`orangepi-build: external/cache/sources/component_cix-next/grub.efi`,
  proven to work with this firmware) and keep our `grub.cfg`.
- **GRUB can't read `/boot/Image` from squashfs**: switch to kernel-on-ESP:
  add an `Image` file-resource to `fwup.conf`, `fat_write` it to `/a/Image`
  and `/b/Image`, and point `grub.cfg`'s `linux` lines at those paths.
- **Kernel hangs after GRUB**: earlycon (`earlycon=pl011,0x040d0000`) shows
  where. Diff the cmdline against the vendor image's
  `grub-post-silicon-orangepi6.cfg` arg by arg; `acpi=force` and
  `efi=noruntime` are load-bearing.

## Boot media: microSD and M.2 NVMe

The same `.fw` boots from either medium. GRUB probes the PARTUUID of the
disk it was loaded from (`probe --part-uuid`), so the kernel and rootfs
always come from the disk the UEFI boot order selected — device names and
partition GUIDs are never hardcoded in the boot path.

- **First medium** (usually the microSD): `mix burn` as usual.
- **Additional media** (e.g. the M.2): burn with *fresh partition GUIDs* so
  `root=PARTUUID` stays unambiguous when both disks are installed:

  ```sh
  # host, M.2 in a USB adapter:
  sudo ./install-to-disk.sh app.fw /dev/sdX
  # or from the running device booted off the SD:
  ./install-to-disk.sh /data/app.fw /dev/nvme0n1
  ```

- Pick which medium boots in the UEFI setup (boot order). Each medium keeps
  its own independent A/B state and KV store, so the SD works as a
  recovery/installer medium alongside the NVMe.

Do **not** write the plain `.fw` to two media of the same machine without
the script — duplicated PARTUUIDs make the kernel's root selection
ambiguous.

## QEMU smoke test (no board needed)

Two-stage validation, both verified:

1. **UEFI + GRUB + squashfs kernel load** — write the `.fw` to a disk image
   (`fwup -a -d disk.img -i app.fw -t complete`), swap `/EFI/BOOT/grub.cfg` on
   the ESP for a `console=ttyAMA0` variant (mtools `mcopy -o`), and boot with
   EDK2 (`edk2-aarch64-code.fd` from the qemu package). GRUB prints
   "Booting slot A..." and loads `/boot/Image` out of the squashfs.
2. **Kernel → erlinit → BEAM → Elixir** — the vendor kernel can't fully run
   under QEMU's ACPI tables (it probes CIX hardware), so boot the same kernel
   binary via QEMU's device-tree path:

   ```sh
   qemu-system-aarch64 -M virt,virtualization=on -cpu cortex-a710 -smp 4 -m 2048 \
     -kernel Image \
     -append "console=ttyAMA0,115200 root=PARTUUID=2fa7efff-0b15-499f-ae82-82986603ca09 rootfstype=squashfs rootwait ro" \
     -drive file=disk.img,format=raw,if=virtio \
     -netdev user,id=n0,hostfwd=tcp::2225-:22 -device virtio-net-pci,netdev=n0 \
     -nographic
   ```

   `virtualization=on` is required: the CIX kernel issues an SMC call at boot
   (`reboot_reason_init`); without it QEMU has no EL2/EL3 and the SMC traps as
   an undefined instruction. `cortex-a710` (ARMv9) is needed — `cortex-a76`
   lacks instructions this kernel uses. Then
   `ssh -p 2225 localhost 'System.version()'` runs Elixir on the guest.

## Provenance

- Kernel: https://github.com/orangepi-xunlong/linux-orangepi branch
  `orange-pi-6.6-cix`, pinned at `f41a4f0b22c0f85a645aa207435761a0123feeaf`.
- Kernel config: `linux-6.6-cix-p1-next.config` from orangepi-build, with
  `CONFIG_R8169=y` (2.5GbE NIC without module loading).
- Boot research and vendor image analysis: see `IMAGE_BUILDING.md` in the
  orangepi-build repo.
