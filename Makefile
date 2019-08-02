THEOS_DEVICE_IP = 192.168.0.6

ARCHS = arm64 arm64e

DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 3DPercentage
3DPercentage_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
