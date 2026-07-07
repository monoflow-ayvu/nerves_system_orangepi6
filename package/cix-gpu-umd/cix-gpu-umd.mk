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
CIX_GPU_UMD_INSTALL_STAGING = YES
# Buildroot libgbm virtual-package provider (see Config.in). libgbm.so
# DT_NEEDs libudev.so.1.
CIX_GPU_UMD_PROVIDES = libgbm
CIX_GPU_UMD_DEPENDENCIES = udev libdrm wayland

CIX_GPU_UMD_BLOBLIB = opt/cixgpu-pro/lib/aarch64-linux-gnu

# Staging gets what other packages link against: the blob's libgbm plus
# mesa's MIT-licensed gbm.h and a matching gbm.pc (the blob exports the
# full mesa 21.3 gbm API, modifiers2/fd_for_plane included). EGL/GLES
# link libs and headers come from libglvnd's own staging install.
define CIX_GPU_UMD_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(CIX_GPU_UMD_PKGDIR)/gbm.h \
		$(STAGING_DIR)/usr/include/gbm.h
	$(INSTALL) -D -m 0644 $(CIX_GPU_UMD_PKGDIR)/gbm.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/gbm.pc
	cp -a $(@D)/$(CIX_GPU_UMD_BLOBLIB)/libgbm.so* $(STAGING_DIR)/usr/lib/
endef

# Vendor payload is a prebuilt filesystem tree — copy it verbatim, then drop
# the ld.so.conf.d fragment (Nerves has no ldconfig and scrub-target.sh
# rejects /etc/ld.so.conf.d). The GL/GBM libs get /usr/lib symlinks so the
# dynamic linker finds them without LD_LIBRARY_PATH, and the glvnd EGL
# vendor ICD goes to glvnd's default search dir.
define CIX_GPU_UMD_INSTALL_TARGET_CMDS
	cp -a $(@D)/opt $(@D)/etc $(@D)/usr $(@D)/lib $(TARGET_DIR)/
	rm -rf $(TARGET_DIR)/etc/ld.so.conf.d $(TARGET_DIR)/etc/ld.so.conf
	for l in libgbm.so.1 libgbm.so libmali.so.0 libmali.so \
		libEGL_cix.so.1 libEGL_cix.so libOpenCL.so.1 libOpenCL.so; do \
		ln -sf /$(CIX_GPU_UMD_BLOBLIB)/$$l $(TARGET_DIR)/usr/lib/$$l || exit 1; \
	done
	$(INSTALL) -D -m 0644 \
		$(@D)/opt/cixgpu-compat/share/glvnd/egl_vendor.d/40_cix.json \
		$(TARGET_DIR)/usr/share/glvnd/egl_vendor.d/40_cix.json
endef

$(eval $(generic-package))
