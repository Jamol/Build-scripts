#!/bin/sh

### copy gas-preprocessor.pl to /usr/local/bin

X264=../x264

#SDKVERSION="9.3"
SDKVERSION=""
DEPLOYMENT_TARGET="9.0"

CURRENTPATH=`pwd`
ARCHS="i386 x86_64 armv7 arm64"
MODULES="libavcodec libavformat libavutil libswresample libswscale"

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
    
	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
	then
		PLATFORM="iPhoneSimulator"
		CFLAGS="$CFLAGS -mios-simulator-version-min=${DEPLOYMENT_TARGET}"
	else
		PLATFORM="iPhoneOS"
		if [ "$ARCH" = "arm64" ]
		then
		    EXPORT="GASPP_FIX_XCODE5=1"
		fi
        CFLAGS="$CFLAGS -fembed-bitcode -mios-version-min=${DEPLOYMENT_TARGET}"
	fi
	
	export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"
	export BUILD_TOOLS="${DEVELOPER}"

	echo "Building ffmpeg for ${PLATFORM} ${SDKVERSION} ${ARCH}"
	echo "Please stand by..."

	#export CC="${BUILD_TOOLS}/usr/bin/gcc"
	
	CURRENTARCHPATH="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
	mkdir -p "${CURRENTARCHPATH}"
	LOG="${CURRENTARCHPATH}/ffmpeg.log"
	
	XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
	CC="xcrun -sdk $XCRUN_SDK clang"

	CXXFLAGS="$CFLAGS"
	LDFLAGS="$CFLAGS"
	
	CFLAGS="$CFLAGS -I$X264"
	LDFLAGS="$LDFLAGS -L$X264/lib/$XCRUN_SDK"

#--sysroot=${CROSS_TOP}/SDKs/${CROSS_SDK} \
	set +e
	./configure --prefix=. \
        --target-os=darwin \
		--arch=$ARCH \
		--cc="$CC" \
        --extra-cflags="$CFLAGS" \
        --extra-ldflags="$LDFLAGS" \
        --enable-cross-compile \
        --disable-debug \
        --disable-programs \
        --disable-doc \
        --enable-pic \
        --enable-gpl \
        --enable-libx264 \
        --disable-stripping \
        --disable-ffmpeg \
        --disable-ffplay \
        --disable-ffprobe \
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
    
    for MODULE in ${MODULES}
    do
        cp ${MODULE}/${MODULE}.a ${CURRENTARCHPATH}
    done
	make clean >> "${LOG}" 2>&1
done

echo "Build library..."
OUTLIBPAHT="${CURRENTPATH}/lib/iphoneos"
mkdir -p ${OUTLIBPAHT}
for MODULE in ${MODULES}
do
    lipo -create ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/${MODULE}.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/${MODULE}.a -output ${OUTLIBPAHT}/${MODULE}.a
done

OUTLIBPAHT="${CURRENTPATH}/lib/iphonesimulator"
mkdir -p ${OUTLIBPAHT}
for MODULE in ${MODULES}
do
    lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/${MODULE}.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/${MODULE}.a -output ${OUTLIBPAHT}/${MODULE}.a
done

#mkdir -p ${CURRENTPATH}/include
#cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/include/openssl ${CURRENTPATH}/include/
echo "Building done."
echo "Done."
