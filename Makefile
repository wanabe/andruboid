all: build.xml
	$(NDK_HOME)/ndk-build
	ant debug install

.PHONY : clean all clean-with-git

build.xml:
	$(ANDROID_HOME)/tools/android update project -p . -t 1

clean: clean-with-git

clean-with-git:
	git clean -fxd
