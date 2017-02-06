#!/bin/sh

CURRENTPATH=`pwd`

CC_VER=4.9
NDK_ROOT=~/android/android-ndk-r10e 
PREBUILT=$NDK_ROOT/toolchains/arm-linux-androideabi-$CC_VER/prebuilt/darwin-x86_64 
PLATFORM=$NDK_ROOT/platforms/android-19/arch-arm

CPU=armv7-a

PREFIX=$(pwd)/android/$CPU

./configure --host=arm-linux \
    --cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
    --enable-shared \
    --enable-pic \
    --disable-cli \
    --sysroot=$PLATFORM \
    --prefix=$PREFIX

make -j4


OUTLIBPAHT="${CURRENTPATH}/lib/android"
mkdir -p ${OUTLIBPAHT}
cp ${CURRENTPATH}/libx264.so ${OUTLIBPAHT}
