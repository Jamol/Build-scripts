#!/bin/sh

### copy gas-preprocessor.pl to /usr/local/bin

SDKVERSION=""

CURRENTPATH=`pwd`
ARCHS="i386 x86_64 armv7 arm64"
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

mkdir -p "${CURRENTPATH}/bin"
mkdir -p "${CURRENTPATH}/lib"

for ARCH in ${ARCHS}
do
    echo "building $ARCH..."
    CFLAGS="-arch $ARCH"
    ASFLAGS=
    
	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
	then
		PLATFORM="iPhoneSimulator"
		if [ "$ARCH" = "x86_64" ]
		then
		    HOST=
		else
			HOST="--host=i386-apple-darwin"
		fi
		CFLAGS="$CFLAGS -mios-simulator-version-min=7.0"
	else
		PLATFORM="iPhoneOS"
		if [ $ARCH = "arm64" ]
		then
		    HOST="--host=aarch64-apple-darwin"
		    XARCH="-arch aarch64"
		else
		    HOST="--host=arm-apple-darwin"
		    XARCH="-arch arm"
		fi
        CFLAGS="$CFLAGS -fembed-bitcode -mios-version-min=7.0"
        ASFLAGS="$CFLAGS"
	fi
	
	export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"
	export BUILD_TOOLS="${DEVELOPER}"

	echo "Building x264 for ${PLATFORM} ${SDKVERSION} ${ARCH}"
	echo "Please stand by..."

	#export CC="${BUILD_TOOLS}/usr/bin/gcc"
	
	CURRENTARCHPATH="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
	mkdir -p "${CURRENTARCHPATH}"
	LOG="${CURRENTARCHPATH}/x264.log"
	
	XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
	CC="xcrun -sdk $XCRUN_SDK clang"
	if [ $PLATFORM = "iPhoneOS" ]
	then
	    export AS="gas-preprocessor.pl $XARCH -- $CC"
	else
	    export -n AS
	fi
	CXXFLAGS="$CFLAGS"
	LDFLAGS="$CFLAGS"

#--sysroot=${CROSS_TOP}/SDKs/${CROSS_SDK} \
	set +e
	CC=$CC ./configure \
        ${HOST} \
        --extra-cflags="$CFLAGS" \
        --extra-asflags="$ASFLAGS" \
        --extra-ldflags="$CFLAGS -L${CROSS_TOP}/SDKs/${CROSS_SDK}/usr/lib/system" \
        --enable-static \
        --enable-pic \
        --disable-cli \
        > "${LOG}" 2>&1

    if [ $? != 0 ];
    then 
    	echo "Problem while configure - Please check ${LOG}"
    	exit 1
    fi

	if [ "$1" == "verbose" ];
	then
		make -j4
	else
		make -j4 >> "${LOG}" 2>&1
	fi
	
	if [ $? != 0 ];
    then 
    	echo "Problem while make - Please check ${LOG}"
    	exit 1
    fi
    
    set -e
    cp libx264.a ${CURRENTARCHPATH}
	make clean >> "${LOG}" 2>&1
done

echo "Build library..."
OUTLIBPAHT="${CURRENTPATH}/lib/iphoneos"
mkdir -p ${OUTLIBPAHT}
lipo -create ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/libx264.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/libx264.a -output ${OUTLIBPAHT}/libx264.a

OUTLIBPAHT="${CURRENTPATH}/lib/iphonesimulator"
mkdir -p ${OUTLIBPAHT}
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/libx264.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/libx264.a -output ${OUTLIBPAHT}/libx264.a

#mkdir -p ${CURRENTPATH}/include
#cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/include/openssl ${CURRENTPATH}/include/
echo "Building done."
echo "Done."
