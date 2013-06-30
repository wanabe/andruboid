LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := andruboid
LOCAL_SRC_FILES := andruboid.c
LOCAL_CFLAGS    := -Wall -Werror
LOCAL_LDFLAGS   := -L$(LOCAL_PATH) -lmruby

include $(BUILD_SHARED_LIBRARY)
