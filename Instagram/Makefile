export ARCHS = arm64 arm64e
export TARGET := iphone:clang:latest:latest

INSTALL_TARGET_PROCESSES = Instagram Preferences # Placeholder so I can kill the settings app and test smh, don't delete

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LetsChangeThoseTexts

LetsChangeThoseTexts_FILES = Tweak.xm
LetsChangeThoseTexts_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += lcttprefs
include $(THEOS_MAKE_PATH)/aggregate.mk