#!/bin/sh

# 1. launch VS native tool command prompt
# 2. run mingw64_shell.bat
# 2. C:\msys64>msys2_shell.cmd -mingw64 -full-path

# copy x264 headers and lib to VC INCLUDE and LIB
# whick link: if it is /usr/bin/link.exe, change it to /usr/bin/link1.exe

# --extra-cflags=/I"$X264_DIR" 
# --extra-ldflags=/LIBPATH:"$X264_DIR"

CURRENTPATH=`pwd`

X264_DIR=../x264
HOST=x86_64-w64-mingw64

./configure --prefix=. \
    --enable-gpl \
    --enable-libx264 \
    --disable-decoder=vp9 \
    --enable-asm \
    --enable-shared \
    --disable-static \
    --disable-stripping \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-avdevice \
    --disable-avfilter \
    --disable-bzlib \
    --disable-iconv \
    --disable-zlib \
    --disable-libopenjpeg \
    --disable-doc \
    --target-os=win64 \
    --arch=x86_64 \
    --toolchain=msvc \
    --extra-cflags="-I$X264_DIR" \
    --extra-ldflags="-LIBPATH:$X264_DIR/lib/win user32.lib"

make

OUTLIBPAHT="${CURRENTPATH}/lib/win"
mkdir -p ${OUTLIBPAHT}

MODULES="avcodec avformat avutil swresample swscale"

for MODULE in ${MODULES}
do
    cp ${CURRENTPATH}/lib${MODULE}/${MODULE}*.dll ${OUTLIBPAHT}
    cp ${CURRENTPATH}/lib${MODULE}/${MODULE}.lib ${OUTLIBPAHT}
done
