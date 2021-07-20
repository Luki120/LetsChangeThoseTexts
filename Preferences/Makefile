export INSTALL_TARGET_PROCESSES += Preferences

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LCTTPreferences

LCTTPreferences_FILES = LCTTRootListController.m LCTTApplicationListController.m LCTTMessagesController.m
LCTTPreferences_CFLAGS = -fobjc-arc
LCTTPreferences_FRAMEWORKS = UIKit
LCTTPreferences_PRIVATE_FRAMEWORKS = Preferences
LCTTPreferences_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk