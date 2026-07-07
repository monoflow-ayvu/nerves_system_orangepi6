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

# Install only the plugin .so files. The blob's private gstreamer 1.22
# core libs (libgstgl/libgstvideo) must NOT ship: /usr/share/cix/lib is
# first on LD_LIBRARY_PATH and they would shadow the system's 1.24 libs.
# The plugins' DT_NEEDED resolve against the system 1.24 libs instead
# (gst plugin ABI is backward compatible). gtk/opengl plugins need
# X11/GLX which this system doesn't have — dropped.
define CIX_GSTREAMER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/cix/lib/gstreamer-1.0
	cp -a $(@D)/usr/share/cix/lib/gstreamer-1.0/*.so \
		$(TARGET_DIR)/usr/share/cix/lib/gstreamer-1.0/
	rm -f $(TARGET_DIR)/usr/share/cix/lib/gstreamer-1.0/libgstgtk.so \
		$(TARGET_DIR)/usr/share/cix/lib/gstreamer-1.0/libgstopengl.so
endef

$(eval $(generic-package))
