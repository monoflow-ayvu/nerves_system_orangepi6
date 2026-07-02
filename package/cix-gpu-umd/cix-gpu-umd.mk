################################################################################
#
# cix-gpu-umd  (proprietary libmali userspace + GPU firmware, runtime install)
#
################################################################################

CIX_GPU_UMD_VERSION = 2.0.0
CIX_GPU_UMD_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/cix-gpu-umd
CIX_GPU_UMD_SITE_METHOD = local
CIX_GPU_UMD_LICENSE = PROPRIETARY
CIX_GPU_UMD_REDISTRIBUTE = NO
CIX_GPU_UMD_INSTALL_STAGING = NO

# Vendor payload is a prebuilt filesystem tree — copy it verbatim, then drop
# the ld.so.conf.d fragment (Nerves has no ldconfig and scrub-target.sh
# rejects /etc/ld.so.conf.d — libmali is reached via LD_LIBRARY_PATH instead).
define CIX_GPU_UMD_INSTALL_TARGET_CMDS
	cp -a $(@D)/opt $(@D)/etc $(@D)/usr $(@D)/lib $(TARGET_DIR)/
	rm -rf $(TARGET_DIR)/etc/ld.so.conf.d $(TARGET_DIR)/etc/ld.so.conf
endef

$(eval $(generic-package))
