# Orange Pi 6 — Nerves System

Custom [Nerves](https://nerves-project.org/) system for the
[Orange Pi 6](http://www.orangepi.org/) (CIX P1 / CD8180 "sky1", 12-core ARM64).

| Feature        | Description                                              |
| -------------- | -------------------------------------------------------- |
| CPU            | CIX P1 (4×A720 + 4×A720 + 4×A520, ARMv9.2)               |
| Memory         | up to 64 GB LPDDR5                                       |
| Storage        | microSD (primary target), NVMe, eMMC                     |
| Linux kernel   | 6.6.89 (orangepi-xunlong `orange-pi-6.6-cix`, ACPI boot) |
| IEx terminal   | debug UART `ttyAMA2`, 115200 8N1                         |
| Ethernet       | yes (in-tree `r8169`/`macb`/`igb`, no firmware needed)   |
| WiFi/BT        | not included (minimal system)                            |

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
  p2  rootfs.a  squashfs, 1 GiB (kernel inside at /boot/Image)
  p3  rootfs.b  squashfs, 1 GiB
  p4  app     ext4, expands to fill the disk, mounted at /root
```

A/B updates follow the `nerves_system_x86_64` model: fwup writes the new
rootfs, then flips `nerves_fw_active` in the uboot-env block and the `boot`
variable in grubenv (written last, so an aborted update never points GRUB at
a half-written slot). On-device revert/validate/status live in
`/usr/share/fwup/ops.fw`.

## Building

The system builds via the Docker build runner (`Dockerfile` in this repo), so
it works on non-FHS hosts like NixOS:

```sh
mix deps.get
mix compile    # builds the whole Buildroot system inside the container
```

Note: your **host** Erlang/OTP major version must match the target's (OTP 29
for nerves_system_br 1.34.0) when building Nerves *applications* against this
system.

## Using

In your Nerves project's `mix.exs`:

```elixir
{:nerves_system_orangepi6, path: "../nerves_system_orangepi6", runtime: false, targets: :orangepi6}
```

Then `MIX_TARGET=orangepi6 mix firmware && mix firmware.burn`.

Serial console: 3-pin debug UART header, 115200 8N1, 3.3 V (do not connect 5 V).

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

## Provenance

- Kernel: https://github.com/orangepi-xunlong/linux-orangepi branch
  `orange-pi-6.6-cix`, pinned at `f41a4f0b22c0f85a645aa207435761a0123feeaf`.
- Kernel config: `linux-6.6-cix-p1-next.config` from orangepi-build, with
  `CONFIG_R8169=y` (2.5GbE NIC without module loading).
- Boot research and vendor image analysis: see `IMAGE_BUILDING.md` in the
  orangepi-build repo.
