INSTALL_TARGET_PROCESSES = Preferences

BUNDLE_NAME = LCTTPreferences

LCTTPreferences_FILES = $(wildcard Controllers/*.m) $(wildcard Cells/*.m)
LCTTPreferences_CFLAGS = -fobjc-arc
LCTTPreferences_FRAMEWORKS = UIKit
LCTTPreferences_PRIVATE_FRAMEWORKS = Preferences
LCTTPreferences_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
