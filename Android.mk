ifeq ($(WPA_SUPPLICANT_VERSION),VER_0_8_X)
    include $(call all-subdir-makefiles)
    LOCAL_CFLAGS+=-O2
    LOCAL_CFLAGS += -fno-strict-aliasing
endif
