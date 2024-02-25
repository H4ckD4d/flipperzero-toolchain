#!/bin/bash

set -euo pipefail;

LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
LINUX_CONFIGURE_ROOT=/toolchain/linux-configure-root

CPUS="$(grep -c processor /proc/cpuinfo)";

function cleanup_relink() {
    local DIRECTORY;
    DIRECTORY="$1";
    find "$DIRECTORY" \
        -type f \
        -name "*.a" \
        -delete;
    rm -rf "$DIRECTORY/share/man"
    relink.sh "$DIRECTORY";
}

function build_python() {
    rm -rf "$LINUX_CONFIGURE_ROOT/python";
    mkdir -p "$LINUX_CONFIGURE_ROOT/python";
    pushd "$LINUX_CONFIGURE_ROOT/python";
    LD_LIBRARY_PATH="$LINUX_OUTPUT_ROOT/lib" /toolchain/src/src/python/configure \
        --prefix="$LINUX_OUTPUT_ROOT" \
        --with-openssl="$LINUX_OUTPUT_ROOT" \
        --with-openssl-rpath="$LINUX_OUTPUT_ROOT" \
        --with-system-ffi \
        --enable-shared \
        LDFLAGS="-L$LINUX_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/ncursesw -I$LINUX_OUTPUT_ROOT/include/readline";
    LD_LIBRARY_PATH="$LINUX_OUTPUT_ROOT/lib" make "-j$CPUS";
    LD_LIBRARY_PATH="$LINUX_OUTPUT_ROOT/lib" make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

build_python;
