export ARCHS = arm64 arm64e
export TARGET := iphone:clang:latest:latest

INSTALL_TARGET_PROCESSES = Instagram

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LetsChangeThoseTexts

LetsChangeThoseTexts_FILES = Tweak.x
LetsChangeThoseTexts_CFLAGS = -fobjc-arc
#LetsChangeThoseTexts_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk