################################################################################
#
# cix-vpu-driver  (ARM Linlon-V8 MVE, amvx.ko, out-of-tree, scons)
#
################################################################################

CIX_VPU_DRIVER_VERSION = 1.0.0
CIX_VPU_DRIVER_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/src
CIX_VPU_DRIVER_SITE_METHOD = file
CIX_VPU_DRIVER_SOURCE = cix-vpu-src.tar.gz
CIX_VPU_DRIVER_LICENSE = GPL-2.0
CIX_VPU_DRIVER_DEPENDENCIES = linux host-scons

CIX_VPU_DRIVER_SUBDIR = vpu_driver
CIX_VPU_DRIVER_KO = bin/aarch64-none-linux-gnu/amvx.ko

# scons reads KDIR/CROSS_COMPILE from the environment (vendor uses
# target=linux). Build the arm64 module against the configured kernel.
define CIX_VPU_DRIVER_BUILD_CMDS
	cd $(@D)/$(CIX_VPU_DRIVER_SUBDIR) && \
	$(TARGET_MAKE_ENV) $(LINUX_MAKE_FLAGS) \
		KDIR=$(LINUX_DIR) CROSS_COMPILE=$(TARGET_CROSS) ARCH=$(KERNEL_ARCH) \
		$(HOST_DIR)/bin/scons target=linux
endef

define CIX_VPU_DRIVER_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra
	$(INSTALL) -m 0644 $(@D)/$(CIX_VPU_DRIVER_SUBDIR)/$(CIX_VPU_DRIVER_KO) \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/
endef

$(eval $(generic-package))
