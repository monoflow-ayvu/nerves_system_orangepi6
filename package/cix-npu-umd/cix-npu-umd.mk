################################################################################
#
# cix-npu-umd  (ArmChina AIPU NPU userspace (libaipudrv), runtime install)
#
################################################################################

CIX_NPU_UMD_VERSION = 1.0.0
CIX_NPU_UMD_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/cix-npu-umd
CIX_NPU_UMD_SITE_METHOD = local
CIX_NPU_UMD_LICENSE = PROPRIETARY
CIX_NPU_UMD_REDISTRIBUTE = NO
CIX_NPU_UMD_INSTALL_STAGING = YES

# Stage the libs + headers so out-of-tree NIFs (e.g. cix_p1_tpu) can cross-link
# against -laipudrv and #include <standard_api.h> at firmware build time.
define CIX_NPU_UMD_INSTALL_STAGING_CMDS
	cp -a $(@D)/usr $(STAGING_DIR)/
endef

define CIX_NPU_UMD_INSTALL_TARGET_CMDS
	cp -a $(@D)/usr $(TARGET_DIR)/
endef

$(eval $(generic-package))
