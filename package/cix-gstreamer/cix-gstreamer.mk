################################################################################
#
# cix-gstreamer  (CIX hardware-accelerated GStreamer plugins, runtime install)
#
################################################################################

CIX_GSTREAMER_VERSION = 1.0.0
CIX_GSTREAMER_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/cix-gstreamer
CIX_GSTREAMER_SITE_METHOD = local
CIX_GSTREAMER_LICENSE = PROPRIETARY
CIX_GSTREAMER_REDISTRIBUTE = NO
CIX_GSTREAMER_INSTALL_STAGING = NO

define CIX_GSTREAMER_INSTALL_TARGET_CMDS
	cp -a $(@D)/usr $(TARGET_DIR)/
endef

$(eval $(generic-package))
