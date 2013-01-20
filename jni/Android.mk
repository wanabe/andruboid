LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := andruboid
LOCAL_C_INCLUDES := jni/mruby/include jni/mruby/src
MRUBY_SRC_FILES := jni/mruby/build/host/src/y.tab.c \
		   jni/mruby/build/host/mrblib/mrblib.c \
		   $(wildcard jni/mruby/src/*.c)
LOCAL_SRC_FILES := andruboid.c app.c mruby/build/host/mrblib/mrblib.c \
		   $(patsubst jni/%, %, $(MRUBY_SRC_FILES))

jni/mruby/bin/mrbc: $(MRUBY_SRC_FILES)

jni/mruby/build/host/mrblib/mrblib.c:
	cd jni/mruby; make

jni/%.c : jni/%.rb jni/mruby/bin/mrbc
	cd jni; mruby/bin/mrbc -B$* $*.rb

include $(BUILD_SHARED_LIBRARY)
