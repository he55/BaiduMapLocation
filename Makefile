DEBUG = 0
# FINALPACKAGE = 1

ARCHS = armv7 arm64
TARGET := iphone:clang:latest:9.0
INSTALL_TARGET_PROCESSES = IphoneCom


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BaiduMapLocation

BaiduMapLocation_FILES = Tweak.x
BaiduMapLocation_CFLAGS = -fobjc-arc
BaiduMapLocation_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
