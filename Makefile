export TARGET := iphone:clang:14.5:latest

SUBPROJECTS += Instagram Preferences Twitter

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
