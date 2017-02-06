#!/bin/sh

# 1. launch VS native tool command prompt
# 2. run mingw64_shell.bat


#CC=cl ./configure --disable-cli --enable-shared --enable-win32thread --extra-cflags="-DNO_PREFIX" --extra-ldflags=-Wl,--output-def=libx264.def

CC=cl ./configure --disable-cli \
    --enable-shared \
    --enable-win32thread
