#!/bin/sh

make clean

_ARCH_=arm64-v8a
case ${_ARCH_} in
    "armeabi")
        _ANDROID_TARGET_SELECT=arch-arm
        _ANDROID_ARCH=arch-arm
        _ANDROID_EABI=arm-linux-androideabi-4.9
        configure_platform="android-armv7" ;;
    "arm64-v8a")
        _ANDROID_TARGET_SELECT=arch-arm64-v8a
        _ANDROID_ARCH=arch-arm64
        _ANDROID_EABI=aarch64-linux-android-4.9
        #no xLIB="/lib64"
        #configure_platform="linux-generic64" ;;
        configure_platform="darwin64-x86_64-cc" ;;
    "mips")
        _ANDROID_TARGET_SELECT=arch-mips
        _ANDROID_ARCH=arch-mips
        _ANDROID_EABI=mipsel-linux-android-4.9
        configure_platform="android" ;;
    "mips64")
        _ANDROID_TARGET_SELECT=arch-mips64
        _ANDROID_ARCH=arch-mips64
        _ANDROID_EABI=mips64el-linux-android-4.9
        xLIB="/lib64"
        configure_platform="linux-generic64" ;;
    "x86")
        _ANDROID_TARGET_SELECT=arch-x86
        _ANDROID_ARCH=arch-x86
        _ANDROID_EABI=x86-4.9
        configure_platform="android-x86" ;;
    "x86_64")
        _ANDROID_TARGET_SELECT=arch-x86_64
        _ANDROID_ARCH=arch-x86_64
        _ANDROID_EABI=x86_64-4.9
        xLIB="/lib64"
        configure_platform="linux-generic64" ;;
    *)
        configure_platform="linux-elf" ;;
esac
    
. ./setenv-openssl-android.sh

#xCFLAGS="-DSHARED_EXTENSION=.so -fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall"
xCFLAGS="-DSHARED_EXTENSION=.so -fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -O3 -fomit-frame-pointer -Wall"

perl -pi -e 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile.org
./config shared no-ssl2 no-ssl3 no-comp no-hw no-engine #$configure_platform $xCFLAGS

make depend
make -j 4 all

CURRENTPATH=`pwd`
OUTLIBPAHT=${CURRENTPATH}/lib/android

mkdir -p ${OUTLIBPAHT}

cp libcrypto.a ${OUTLIBPAHT}
cp libcrypto.so ${OUTLIBPAHT}
cp libssl.a ${OUTLIBPAHT}
cp libssl.so ${OUTLIBPAHT}
