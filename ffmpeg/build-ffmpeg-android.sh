#!/bin/sh

CURRENTPATH=`pwd`

CC_VER=4.9
NDK_ROOT=~/android/android-ndk-r10e 
PREBUILT=$NDK_ROOT/toolchains/arm-linux-androideabi-$CC_VER/prebuilt/darwin-x86_64 
PLATFORM=$NDK_ROOT/platforms/android-19/arch-arm

CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
PREFIX=$(pwd)/android/$CPU
ADDITIONAL_CONFIGURE_FLAG=

ADDI_CFLAGS="-DANDROID -DNDEBUG -marm -march=$CPU" 

X264_DIR=../x264

./configure --prefix=. \
    --prefix=$PREFIX \
    --enable-gpl \
    --enable-libx264 \
    --disable-decoder=vp9 \
    --enable-shared \
    --disable-static \
    --enable-pthreads \
    --disable-stripping \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffserver \
    --disable-ffprobe \
    --disable-avdevice \
    --enable-thumb \
    --enable-cross-compile \
    --extra-libs="-lgcc" \
    --cc=$PREBUILT/bin/arm-linux-androideabi-gcc \
    --cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
    --nm=$PREBUILT/bin/arm-linux-androideabi-nm \
    --target-os=linux \
    --arch=arm \
    --cpu=$CPU \
    --sysroot=$PLATFORM \
    --extra-cflags="-I$X264_DIR -Os -fPIC $ADDI_CFLAGS" \
    --disable-asm \
    --enable-neon \
    --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib \
    -L$PLATFORM/usr/lib \
    -L$X264_DIR/lib/android \
    -nostdlib -lc -lm -ldl -llog"

make

OUTLIBPAHT="${CURRENTPATH}/lib/android"
mkdir -p ${OUTLIBPAHT}

MODULES="libavcodec libavformat libavutil libswresample libswscale"

for MODULE in ${MODULES}
do
    cp ${CURRENTPATH}/${MODULE}/${MODULE}-*.so ${OUTLIBPAHT}
done

