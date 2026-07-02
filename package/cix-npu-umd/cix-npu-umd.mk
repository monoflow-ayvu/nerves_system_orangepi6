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
CIX_NPU_UMD_INSTALL_STAGING = NO

define CIX_NPU_UMD_INSTALL_TARGET_CMDS
	cp -a $(@D)/usr $(TARGET_DIR)/
endef

$(eval $(generic-package))
