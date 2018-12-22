#!/bin/sh

CURRENTPATH=`pwd`

X264=../x264

CFLAGS="-I$X264"
LDFLAGS="-L$X264/lib/osx"
	
./configure --prefix=./lib/osx \
    --logfile=./config.log \
    --enable-gpl \
    --enable-libx264 \
    --enable-rpath \
    --disable-libvpx \
    --disable-decoder=vp9 \
    --enable-shared \
    --enable-pthreads \
    --disable-stripping \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-avfilter \
    --disable-ffprobe \
    --cc=clang \
    --extra-cflags="$CFLAGS" \
    --extra-ldflags="$LDFLAGS"

make -j4

OUTLIBPAHT="${CURRENTPATH}/lib/osx"
mkdir -p ${OUTLIBPAHT}

MODULES="libavcodec libavformat libavutil libswresample libswscale"

for MODULE in ${MODULES}
do
    cp ${CURRENTPATH}/${MODULE}/${MODULE}.a ${OUTLIBPAHT}
    cp ${CURRENTPATH}/${MODULE}/${MODULE}*.dylib ${OUTLIBPAHT}
done
