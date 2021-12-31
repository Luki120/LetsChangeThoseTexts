export ARCHS = arm64 arm64e
export TARGET := iphone:clang:latest:latest

SUBPROJECTS += Instagram Preferences Twitter

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
