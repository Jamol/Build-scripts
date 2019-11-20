#!/bin/sh

#  Automatic build script for libssl and libcrypto 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Felix Schulze on 16.12.10.
#  Copyright 2010 Felix Schulze. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#  Change values here													  #
#				                                                          #
VERSION="1.1.1"													          #
#SDKVERSION="9.3"														  #
#																		  #
###########################################################################
#																		  #
# Don't change anything under this line!								  #
#																		  #
###########################################################################

make clean

CURRENTPATH=`pwd`
ARCHS="x86_64 arm64 armv7s"
DEVELOPER=`xcode-select -print-path`

if [ ! -d "$DEVELOPER" ]; then
  echo "xcode path is not set correctly $DEVELOPER does not exist (most likely because of xcode > 4.3)"
  echo "run"
  echo "sudo xcode-select -switch <xcode path>"
  echo "for default installation:"
  echo "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

case $DEVELOPER in  
     *\ * )
           echo "Your Xcode path contains whitespaces, which is not supported."
           exit 1
          ;;
esac

case $CURRENTPATH in  
     *\ * )
           echo "Your path contains whitespaces, which is not supported by 'make install'."
           exit 1
          ;;
esac

set -e
#if [ ! -e openssl-${VERSION}.tar.gz ]; then
#	echo "Downloading openssl-${VERSION}.tar.gz"
#    curl -O http://www.openssl.org/source/openssl-${VERSION}.tar.gz
#else
#	echo "Using openssl-${VERSION}.tar.gz"
#fi

#mkdir -p "${CURRENTPATH}/src"

mkdir -p "${CURRENTPATH}/bin"
mkdir -p "${CURRENTPATH}/lib"

#tar zxf openssl-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
#cd "${CURRENTPATH}/src/openssl-${VERSION}"

for ARCH in ${ARCHS}
do
	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
		PLATFORM="iPhoneSimulator"
		TARGET="iossim-cross"
		if [[ "${ARCH}" == "x86_64" ]]; then
			TARGET="ios64sim-cross"
		fi
	elif [ "${ARCH}" == "tv_x86_64" ]; then
		ARCH="x86_64"
		PLATFORM="AppleTVSimulator"
		TARGET="tvossim-cross"
	elif [ "${ARCH}" == "tv_arm64" ]; then
		ARCH="arm64"
		PLATFORM="AppleTVOS"
		TARGET="tvos64-cross"
	else
		#sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"
		PLATFORM="iPhoneOS"
		TARGET="ios-cross"
		if [[ "${ARCH}" == "arm64" ]]; then
			TARGET="ios64-cross"
		fi
	fi
	 
	export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"
	export BUILD_TOOLS="${DEVELOPER}"
	#export CROSS_COMPILE=`xcode-select --print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/

	CURRENTARCHPATH="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
	mkdir -p "${CURRENTARCHPATH}"
	LOG="${CURRENTARCHPATH}/build-openssl-${VERSION}.log"

	if [[ "${VERSION}" == "1.1."* ]]; then
		LOCAL_CONFIG_OPTIONS="${TARGET} --prefix=${CURRENTARCHPATH} no-async no-shared no-engine"
	else
		export CC="${BUILD_TOOLS}/usr/bin/gcc -fembed-bitcode -arch ${ARCH}"
		if [ "${ARCH}" == "x86_64" ]; then
			LOCAL_CONFIG_OPTIONS="darwin64-x86_64-cc --openssldir='${CURRENTARCHPATH}'"
		else
			LOCAL_CONFIG_OPTIONS="BSD-generic32 --openssldir='${CURRENTARCHPATH}'"
			#LOCAL_CONFIG_OPTIONS="iphoneos-cross --openssldir='${CURRENTARCHPATH}'"
		fi
	fi

	set +e
	CONFIG_CMD="./Configure ${LOCAL_CONFIG_OPTIONS}"
	echo ARCH=${ARCH} CONFIG=${CONFIG_CMD}
	echo "Building openssl-${VERSION} for ${PLATFORM} ${SDKVERSION} ${ARCH}"
	echo "Please stand by..."

	${CONFIG_CMD} > "${LOG}" 2>&1
    
    if [ $? != 0 ];
    then 
    	echo "Problem while configure - Please check ${LOG}"
    	exit 1
    fi

	# add -isysroot to CC=
	if [[ "${VERSION}" != "1.1."* ]]; then
		sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=7.0 !" "Makefile"
	fi

	if [ "$1" == "verbose" ];
	then
		make build_libs
	else
		make build_libs >> "${LOG}" 2>&1
	fi
	
	if [ $? != 0 ];
    then 
    	echo "Problem while make - Please check ${LOG}"
    	exit 1
    fi
    
    set -e
    cp libcrypto.a ${CURRENTARCHPATH}
    cp libssl.a ${CURRENTARCHPATH}
	#make install >> "${LOG}" 2>&1
	make clean >> "${LOG}" 2>&1
done


echo "Build library..."
OUTLIBPAHT="${CURRENTPATH}/lib/iphoneos"
mkdir -p ${OUTLIBPAHT}
lipo -create ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/libssl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/libssl.a -output ${OUTLIBPAHT}/libssl.a
lipo -create ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/libcrypto.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/libcrypto.a -output ${OUTLIBPAHT}/libcrypto.a

OUTLIBPAHT="${CURRENTPATH}/lib/iphonesimulator"
mkdir -p ${OUTLIBPAHT}
cp ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/libssl.a ${OUTLIBPAHT}/libssl.a
cp ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/libcrypto.a ${OUTLIBPAHT}/libcrypto.a


echo "Building done."
echo "Cleaning up..."
#rm -rf ${CURRENTPATH}/src/openssl-${VERSION}
echo "Done."
