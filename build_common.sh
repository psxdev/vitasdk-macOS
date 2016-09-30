#!/bin/bash

HOST_NATIVE=x86_64-apple-darwin10

LIBICONV_VERSION=1.14
GMP_VERSION=6.1.1
MPFR_VERSION=3.1.4
MPC_VERSION=1.0.3
ISL_VERSION=0.17.1
ZLIB_VERSION=1.2.8
LIBZIP_VERSION=1.1.3
LIBELF_VERSION=0.8.13
JANSSON_VERSION=2.8
DLFCN_VERSION=1.0.0
BINUTILS_VERSION=2.27
GCC_VERSION=6.2.0

JOBS=-j4

ROOTDIR=`pwd`
PATCHDIR=${ROOTDIR}/patch
DOWNLOADDIR=${ROOTDIR}/download
SRCDIR=${ROOTDIR}/src
BUILDDIR=${ROOTDIR}/build
mkdir -p ${SRCDIR} ${BUILDDIR}
SRCRELDIR=../src
INSTALLDIR=${ROOTDIR}/install
VITASDKROOT=${ROOTDIR}/vitasdk


# Strip binary files as in "strip binary" form, for both native(linux/mac) and mingw.
strip_binary() {
    set +e
    if [ $# -ne 2 ] ; then
        warning "strip_binary: Missing arguments"
        return 0
    fi
    local strip="$1"
    local bin="$2"

    file $bin | grep -q  "(\bELF\b)|(\bPE\b)|(\bPE32\b)"
    if [ $? -eq 0 ]; then
        $strip $bin 2>/dev/null || true
    fi

    set -e
}
