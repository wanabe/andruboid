LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := andruboid
LOCAL_C_INCLUDES := jni/mruby/include jni/mruby/src
LOCAL_SRC_FILES := andruboid.c app.c \
		   mruby/build/host/mrblib/mrblib.c \
		   mruby/build/host/src/y.tab.c \
		   $(patsubst jni/%, %, $(wildcard jni/mruby/src/*.c))
jni/mruby/build/host/mrblib/mrblib.c:
	cd jni/mruby; make
jni/%.c : jni/%.rb
	cd jni; mruby/bin/mrbc -B$* $*.rb
include $(BUILD_SHARED_LIBRARY)
