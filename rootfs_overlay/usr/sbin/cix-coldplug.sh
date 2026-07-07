#!/bin/sh
# Bring up udev and the CIX accelerator/display drivers before the Elixir
# application starts. Run from erlinit.config via --pre-run-exec.
#
# Nerves uses BR2_INIT_NONE (no init system), so nothing else starts udevd
# or coldplugs devices. weston/cog/libinput need udev-populated /dev/input
# and /dev/dri nodes, and the proprietary mali_kbase stack must be loaded in
# dependency order (it is blacklisted from auto-probe in modprobe.d).

set -e

# 1. Dynamic device management (eudev). Start the daemon and coldplug.
if [ -x /sbin/udevd ] || [ -x /usr/sbin/udevd ]; then
    mkdir -p /run/udev
    udevd --daemon 2>/dev/null || /sbin/udevd --daemon 2>/dev/null || true
    udevadm trigger --type=subsystems --action=add 2>/dev/null || true
    udevadm trigger --type=devices --action=add 2>/dev/null || true
    udevadm settle --timeout=10 2>/dev/null || true
fi

# 2. Display pipeline (in-tree CIX DRM is built-in; DPU/DP-TX/panel are modules
#    with ACPI HIDs — load them so /dev/dri/card0 appears).
for m in linlondp trilin_dpsub cix_edp_panel; do
    modprobe "$m" 2>/dev/null || true
done

# 3. GPU: proprietary mali_kbase in strict dependency order.
for m in protected_memory_allocator memory_group_manager mali_kbase; do
    modprobe "$m" 2>/dev/null || true
done

# 4. NPU (/dev/aipu) and VPU (V4L2 M2M /dev/video*).
modprobe aipu 2>/dev/null || true
modprobe amvx 2>/dev/null || true

# 5. A/B bookkeeping: if GRUB's boot-once rollback fell back to the other
#    slot, grubenv already points at the good slot but the Nerves KV store
#    still names the failed one. Realign it before the BEAM reads it.
if [ -f /usr/share/fwup/ops.fw ] && [ -b /dev/rootdisk0 -o -L /dev/rootdisk0 ]; then
    fwup -t reconcile -d /dev/rootdisk0 -q -U /usr/share/fwup/ops.fw || true
fi

exit 0
