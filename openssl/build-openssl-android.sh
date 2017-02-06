#!/bin/sh

make clean

. ./setenv-openssl-android.sh

perl -pi -e 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile.org
./config shared no-ssl2 no-ssl3 no-comp no-hw

make depend
make -j 4 all

CURRENTPATH=`pwd`
OUTLIBPAHT=${CURRENTPATH}/lib/android

mkdir -p ${OUTLIBPAHT}

cp libcrypto.a ${OUTLIBPAHT}
cp libcrypto.so ${OUTLIBPAHT}
cp libssl.a ${OUTLIBPAHT}
cp libssl.so ${OUTLIBPAHT}