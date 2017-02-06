#!/bin/bash

make clean

OPENSSL_VERSION="1.0.2g.6.0.4"

CURRENTPATH=`pwd`

set -e
mkdir -p "${CURRENTPATH}/bin"
mkdir -p "${CURRENTPATH}/lib"

PLATFORM=osx
ARCHS="i386 x86_64"

for ARCH in ${ARCHS}
do
    echo "Building openssl-${OPENSSL_VERSION} for ${PLATFORM} ${ARCH}"
    CURRENTARCHPATH="${CURRENTPATH}/bin/${PLATFORM}-${ARCH}"
    mkdir -p "${CURRENTARCHPATH}"
    
    export CC="${BUILD_TOOLS}/usr/bin/clang -fembed-bitcode"
    
    if [ "${ARCH}" == "i386" ]; then
		./Configure darwin-i386-cc --openssldir="${CURRENTARCHPATH}"
	else
		./Configure darwin64-x86_64-cc --openssldir="${CURRENTARCHPATH}"
	fi
	
	if [ $? != 0 ]; then 
    	echo "Problem while configure - Please check ${LOG}"
    	exit 1
    fi
    
    make clean
    make -j 4
    if [ $? != 0 ]; then 
        echo "Problem while make - Please check ${LOG}"
        exit 1
    fi
    cp libcrypto.a ${CURRENTARCHPATH}
    cp libssl.a ${CURRENTARCHPATH}
done

#curl -O http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
#tar -xvzf ciscossl-$OPENSSL_VERSION.tar.gz
#mv ciscossl-$OPENSSL_VERSION ciscossl_i386
#tar -xvzf ciscossl-$OPENSSL_VERSION.tar.gz
#mv ciscossl-$OPENSSL_VERSION ciscossl_x86_64
#cd ciscossl_i386
#./Configure darwin-i386-cc
#make
#cd ../
#cd ciscossl_x86_64
#./Configure darwin64-x86_64-cc
#make


OUTLIBPAHT="${CURRENTPATH}/lib/osx"
mkdir -p ${OUTLIBPAHT}

lipo -create ${CURRENTPATH}/bin/osx-i386/libcrypto.a ${CURRENTPATH}/bin/osx-x86_64/libcrypto.a -output ${OUTLIBPAHT}/libcrypto.a
lipo -create ${CURRENTPATH}/bin/osx-i386/libssl.a ${CURRENTPATH}/bin/osx-x86_64/libssl.a -output ${OUTLIBPAHT}/libssl.a
#rm openssl-$OPENSSL_VERSION.tar.gz