################################################################################
#
# cix-npu-driver  (ArmChina Zhouyi V3 AIPU, out-of-tree)
#
################################################################################

CIX_NPU_DRIVER_VERSION = 5.11.0
CIX_NPU_DRIVER_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/src
CIX_NPU_DRIVER_SITE_METHOD = file
CIX_NPU_DRIVER_SOURCE = cix-npu-src.tar.gz
CIX_NPU_DRIVER_LICENSE = GPL-2.0
CIX_NPU_DRIVER_DEPENDENCIES = linux

CIX_NPU_DRIVER_DRV_DIR = npu_driver/driver
CIX_NPU_DRIVER_MAKE_ENV = \
	$(LINUX_MAKE_FLAGS) \
	COMPASS_DRV_BTENVAR_ARCH=$(KERNEL_ARCH) \
	COMPASS_DRV_BTENVAR_KMD_DIR=. \
	COMPASS_DRV_BTENVAR_KMD_VERSION=$(CIX_NPU_DRIVER_VERSION) \
	COMPASS_DRV_BTENVAR_KPATH=$(LINUX_DIR) \
	BUILD_AIPU_VERSION_KMD=BUILD_ZHOUYI_V3 \
	BUILD_TARGET_PLATFORM_KMD=BUILD_PLATFORM_SKY1 \
	BUILD_NPU_DEVFREQ=y

# The vendor injects the AIPU UAPI header into the kernel tree before build.
define CIX_NPU_DRIVER_COPY_UAPI
	$(INSTALL) -m 0644 \
		$(@D)/$(CIX_NPU_DRIVER_DRV_DIR)/armchina-npu/include/armchina_aipu.h \
		$(LINUX_DIR)/include/uapi/misc/armchina_aipu.h
endef
CIX_NPU_DRIVER_PRE_BUILD_HOOKS += CIX_NPU_DRIVER_COPY_UAPI

define CIX_NPU_DRIVER_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(CIX_NPU_DRIVER_MAKE_ENV) $(MAKE) \
		-C $(@D)/$(CIX_NPU_DRIVER_DRV_DIR) \
		ARCH=$(KERNEL_ARCH) CROSS_COMPILE=$(TARGET_CROSS)
endef

define CIX_NPU_DRIVER_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra
	$(INSTALL) -m 0644 $(@D)/$(CIX_NPU_DRIVER_DRV_DIR)/aipu.ko \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/
endef

$(eval $(generic-package))
