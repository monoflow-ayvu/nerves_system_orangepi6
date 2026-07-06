################################################################################
#
# cix-noe-umd  (CIX NOE NPU runtime (libnoe), runtime install)
#
################################################################################

CIX_NOE_UMD_VERSION = 1.0.0
CIX_NOE_UMD_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/cix-noe-umd
CIX_NOE_UMD_SITE_METHOD = local
CIX_NOE_UMD_LICENSE = PROPRIETARY
CIX_NOE_UMD_REDISTRIBUTE = NO
CIX_NOE_UMD_INSTALL_STAGING = YES

# Stage the libs + headers so out-of-tree NIFs (e.g. cix_p1_tpu) can cross-link
# against -lnoe and #include <cix_noe_standard_api.h> at firmware build time.
define CIX_NOE_UMD_INSTALL_STAGING_CMDS
	cp -a $(@D)/usr $(STAGING_DIR)/
endef

define CIX_NOE_UMD_INSTALL_TARGET_CMDS
	cp -a $(@D)/usr $(TARGET_DIR)/
endef

$(eval $(generic-package))
