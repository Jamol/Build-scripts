#!/bin/sh

CURRENTPATH=`pwd`
OUTLIBPAHT=${CURRENTPATH}/lib/android

echo ANDROID_NDK_HOME=${ANDROID_NDK_HOME}


ANDROID_TOOLCHAIN=""
for host in "linux-x86_64" "linux-x86" "darwin-x86_64" "darwin-x86"
do
  #if [ -d "$ANDROID_NDK_HOME/toolchains/$_ANDROID_EABI/prebuilt/$host" ]; then
  #  ANDROID_TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/$_ANDROID_EABI/prebuilt/$host"
  if [ -d "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$host" ]; then
    ANDROID_TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$host"
    break
  fi
done

echo ANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN

# Only modify/export PATH if ANDROID_TOOLCHAIN good
if [ ! -z "$ANDROID_TOOLCHAIN" ]; then
  export PATH="$ANDROID_TOOLCHAIN/bin":"$PATH"
fi

build_one_arch()
{
  # Only modify/export PATH if ANDROID_TOOLCHAIN good
  if [ ! -z "$ANDROID_TOOLCHAIN" ]; then
    export PATH="$ANDROID_TOOLCHAIN/$TRIBLE/bin":"$PATH"
  fi
  
  make clean
  
  ./Configure $SSL_TARGET $OPTIONS -DSHARED_EXTENSION=.so -fuse-ld="$ANDROID_TOOLCHAIN/$TRIBLE/bin/ld" \
			  zlib \
			  shared \
			  no-asm \
			  no-tests \
              no-unit-test

  make depend
  make -j 4 all


  mkdir -p ${OUTLIBPAHT}/${_ARCH_}

  cp libcrypto.a ${OUTLIBPAHT}/${_ARCH_}
  cp libcrypto.so ${OUTLIBPAHT}/${_ARCH_}
  cp libssl.a ${OUTLIBPAHT}/${_ARCH_}
  cp libssl.so ${OUTLIBPAHT}/${_ARCH_}
}


_API_LEVEL="26"

BUILD_ARCHS="armeabi armeabi-v7a arm64-v8a x86 x86_64"

#_ARCH_=arm64-v8a
#_ARCH_=x86
#_ARCH_=armeabi
for _ARCH_ in ${BUILD_ARCHS}
do
  case ${_ARCH_} in
    "armeabi")
        TRIBLE="arm-linux-androideabi"
        _ANDROID_EABI="arm-linux-androideabi-4.9"
        OPTIONS="--target=armv5te-linux-androideabi -mthumb -fPIC -latomic -D__ANDROID_API__=$_API_LEVEL"
        DESTDIR="$OUTLIBPAHT/armeabi"
        SSL_TARGET="android-arm"
    ;;
    "armeabi-v7a")
        TRIBLE="arm-linux-androideabi"
        TC_NAME="arm-linux-androideabi-4.9"
        OPTIONS="--target=armv7a-linux-androideabi -Wl,--fix-cortex-a8 -fPIC -D__ANDROID_API__=$_API_LEVEL"
        DESTDIR="$OUTLIBPAHT/armeabi-v7a"
        SSL_TARGET="android-arm"
    ;;
    "arm64-v8a")
        TRIBLE="aarch64-linux-android"
        _ANDROID_EABI="aarch64-linux-android-4.9"
        OPTIONS="-fPIC -D__ANDROID_API__=$_API_LEVEL"
        DESTDIR="$OUTLIBPAHT/arm64-v8a"
        SSL_TARGET="android-arm64"
    ;;
    "x86")
        TRIBLE="i686-linux-android"
        _ANDROID_EABI="x86-4.9"
        OPTIONS="-fPIC -D__ANDROID_API__=$_API_LEVEL"
        DESTDIR="$OUTLIBPAHT/x86"
        SSL_TARGET="android-x86"
    ;;
    "x86_64")
        TRIBLE="x86_64-linux-android"
        _ANDROID_EABI="x86_64-4.9"
        OPTIONS="-fPIC -D__ANDROID_API__=$_API_LEVEL"
        DESTDIR="$OUTLIBPAHT/x86_64"
        SSL_TARGET="android-x86_64"
    ;;
    *)
        SSL_TARGET="linux-elf" ;;
  esac
  
  build_one_arch
  
done

