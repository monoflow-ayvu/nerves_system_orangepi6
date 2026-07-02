################################################################################
#
# cix-vpu-firmware  (CIX Linlon-V8 VPU codec firmware (.fwb), runtime install)
#
################################################################################

CIX_VPU_FIRMWARE_VERSION = 1.0.0
CIX_VPU_FIRMWARE_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/cix-vpu-firmware
CIX_VPU_FIRMWARE_SITE_METHOD = local
CIX_VPU_FIRMWARE_LICENSE = PROPRIETARY
CIX_VPU_FIRMWARE_REDISTRIBUTE = NO
CIX_VPU_FIRMWARE_INSTALL_STAGING = NO

define CIX_VPU_FIRMWARE_INSTALL_TARGET_CMDS
	cp -a $(@D)/lib $(TARGET_DIR)/
endef

$(eval $(generic-package))
