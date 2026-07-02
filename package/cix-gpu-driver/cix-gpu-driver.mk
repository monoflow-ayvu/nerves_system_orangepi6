################################################################################
#
# cix-gpu-driver  (ARM Mali "sky1" mali_kbase, out-of-tree)
#
################################################################################

CIX_GPU_DRIVER_VERSION = 1.0.0
CIX_GPU_DRIVER_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/src
CIX_GPU_DRIVER_SITE_METHOD = file
CIX_GPU_DRIVER_SOURCE = cix-gpu-src.tar.gz
CIX_GPU_DRIVER_LICENSE = GPL-2.0 (kbase), proprietary
CIX_GPU_DRIVER_DEPENDENCIES = linux

# Vendor build env (see orangepi-build cix.conf family_tweaks_kernel §7c)
CIX_GPU_DRIVER_DIR_REL = gpu_kernel/drivers
CIX_GPU_DRIVER_MAKE_ENV = \
	$(LINUX_MAKE_FLAGS) \
	CONFIG_MALI_BASE_MODULES=y \
	CONFIG_MALI_MEMORY_GROUP_MANAGER=y \
	CONFIG_MALI_PROTECTED_MEMORY_ALLOCATOR=y \
	CONFIG_MALI_PLATFORM_NAME="sky1" \
	CONFIG_MALI_CSF_SUPPORT=y \
	CONFIG_MALI_CIX_POWER_MODEL=y \
	KDIR=$(LINUX_DIR)

define CIX_GPU_DRIVER_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(CIX_GPU_DRIVER_MAKE_ENV) $(MAKE) -C \
		$(@D)/$(CIX_GPU_DRIVER_DIR_REL)/base/arm/
	$(TARGET_MAKE_ENV) $(CIX_GPU_DRIVER_MAKE_ENV) $(MAKE) -C \
		$(@D)/$(CIX_GPU_DRIVER_DIR_REL)/gpu/arm/
endef

define CIX_GPU_DRIVER_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra
	$(INSTALL) -m 0644 \
		$(@D)/$(CIX_GPU_DRIVER_DIR_REL)/base/arm/memory_group_manager/memory_group_manager.ko \
		$(@D)/$(CIX_GPU_DRIVER_DIR_REL)/base/arm/protected_memory_allocator/protected_memory_allocator.ko \
		$(@D)/$(CIX_GPU_DRIVER_DIR_REL)/gpu/arm/midgard/mali_kbase.ko \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/
endef

$(eval $(generic-package))
