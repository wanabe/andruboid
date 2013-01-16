# Andruboid

Andruboid is Android apprication framework with mruby.
This is released under the MIT license.

# !! WARNING

This is very experimental.
Everything is under construction and fluid.

## requirements

* Android SDK
* Android NDK
* JDK
* ant

## how to build and install

    # make ANDROID_HOME=/path/to/android-sdk NDK_HOME=/path/to/android-ndk

## tool

androvm.sh provides easy way to debug.
It requires AndroVM Player and AndroVM on VirtualBox.
You can type:

    # AVM="VM Name" ADB=/path/to/adb AVMPLAYER_DIR=/dir/of/AndroVMplayer \
      ./androvm.sh

## License

Copyright (c) 2013 wanabe

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
