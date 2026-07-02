################################################################################
#
# cix-audio-dsp  (CIX audio DSP firmware + offload codecs, runtime install)
#
################################################################################

CIX_AUDIO_DSP_VERSION = 1.0.0
CIX_AUDIO_DSP_SITE = $(NERVES_DEFCONFIG_DIR)/blobs/cix-audio-dsp
CIX_AUDIO_DSP_SITE_METHOD = local
CIX_AUDIO_DSP_LICENSE = PROPRIETARY
CIX_AUDIO_DSP_REDISTRIBUTE = NO
CIX_AUDIO_DSP_INSTALL_STAGING = NO

define CIX_AUDIO_DSP_INSTALL_TARGET_CMDS
	cp -a $(@D)/usr $(TARGET_DIR)/
endef

$(eval $(generic-package))
