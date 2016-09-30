#!/bin/bash


if [ $# -gt 0 ]; then
  while test $# -gt 0
  do
    case "$1" in
      --help) (echo "Supported steps: gcc-deps toolchain-deps toolchain dlfcn binutils gcc headers newlib pthread gcc-final strip"; exit 1)
        ;;
      gcc-deps) STEP1=true
        ;;
      toolchain-deps) STEP2=true
        ;;
      toolchain) STEP3=true
        ;;
      binutils) STEP4=true
        ;;
      gcc) STEP5=true
        ;;
      headers) STEP6=true
        ;;
      newlib) STEP7=true
        ;;
      pthread) STEP8=true
        ;;
      gcc-final) STEP9=true
        ;;
      strip) STEP10=true
        ;;
      *) (echo "Unsupported $1"; exit 1)
        ;;
    esac
    shift
  done
else
  STEP1=true
  STEP2=true
  STEP3=true
  STEP4=true
  STEP5=true
  STEP6=true
  STEP7=true
  STEP8=true
  STEP9=true
  STEP10=true
fi

. ./build_common.sh

set -e
set -o pipefail

mkdir -p ${DOWNLOADDIR} ${SRCDIR} ${BUILDDIR} ${INSTALLDIR}

if [ ${STEP1} ]; then
  echo "[Step 1.1] Build libiconv..."
  cd ${DOWNLOADDIR}
  if [ ! -f libiconv-${LIBICONV_VERSION}.tar.gz ]; then
	curl -L -O http://ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz
  fi
  tar xzf libiconv-${LIBICONV_VERSION}.tar.gz -C ${SRCDIR}
  rm -rf ${BUILDDIR}/libiconv-${LIBICONV_VERSION}
  mkdir -p ${BUILDDIR}/libiconv-${LIBICONV_VERSION}
  cd ${BUILDDIR}/libiconv-${LIBICONV_VERSION}
  ../${SRCRELDIR}/libiconv-${LIBICONV_VERSION}/configure --build=${HOST_NATIVE} --host=${HOST_NATIVE} --prefix=${INSTALLDIR} --disable-shared --disable-nls
  make ${JOBS}
  make install

  echo "[Step 1.2] Build GMP..."
  cd ${DOWNLOADDIR}
  if [ ! -f gmp-${GMP_VERSION}.tar.xz ]; then
	curl -L -O http://ftp.gnu.org/gnu/gmp/gmp-${GMP_VERSION}.tar.xz
  fi
  tar xJf gmp-${GMP_VERSION}.tar.xz -C ${SRCDIR}
  rm -rf ${BUILDDIR}/gmp-${GMP_VERSION}
  mkdir -p ${BUILDDIR}/gmp-${GMP_VERSION}
  cd ${BUILDDIR}/gmp-${GMP_VERSION}
  ../${SRCRELDIR}/gmp-${GMP_VERSION}/configure --build=${HOST_NATIVE} --host=${HOST_NATIVE} --prefix=${INSTALLDIR} --disable-shared --enable-cxx
  make ${JOBS}
  make install

  echo "[Step 1.3] Build MPFR..."
  cd ${DOWNLOADDIR}
  if [ ! -f mpfr-${MPFR_VERSION}.tar.xz ]; then
	curl -L -O http://ftp.gnu.org/gnu/mpfr/mpfr-${MPFR_VERSION}.tar.xz
  fi
  tar xJf mpfr-${MPFR_VERSION}.tar.xz -C ${SRCDIR}
  rm -rf ${BUILDDIR}/mpfr-${MPFR_VERSION}
  mkdir -p ${BUILDDIR}/mpfr-${MPFR_VERSION}
  cd ${BUILDDIR}/mpfr-${MPFR_VERSION}
  ../${SRCRELDIR}/mpfr-${MPFR_VERSION}/configure --build=${HOST_NATIVE} --host=${HOST_NATIVE} --prefix=${INSTALLDIR} --disable-shared --with-gmp=${INSTALLDIR}
  make ${JOBS}
  make install

  echo "[Step 1.4] Build MPC..."
  cd ${DOWNLOADDIR}
  if [ ! -f mpc-${MPC_VERSION}.tar.gz ]; then
	curl -L -O http://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz
  fi
  tar xzf mpc-${MPC_VERSION}.tar.gz -C ${SRCDIR}
  rm -rf ${BUILDDIR}/mpc-${MPC_VERSION}
  mkdir -p ${BUILDDIR}/mpc-${MPC_VERSION}
  cd ${BUILDDIR}/mpc-${MPC_VERSION}
  ../${SRCRELDIR}/mpc-${MPC_VERSION}/configure --build=${HOST_NATIVE} --host=${HOST_NATIVE} --prefix=${INSTALLDIR} --disable-shared --with-gmp=${INSTALLDIR} --with-mpfr=${INSTALLDIR}
  make ${JOBS}
  make install

  echo "[Step 1.5] Build ISL..."
  cd ${DOWNLOADDIR}
  if [ ! -f isl-${ISL_VERSION}.tar.xz ]; then
	curl -L -O http://isl.gforge.inria.fr/isl-${ISL_VERSION}.tar.xz
  fi
  tar xJf isl-${ISL_VERSION}.tar.xz -C ${SRCDIR}
  rm -rf ${BUILDDIR}/isl-${ISL_VERSION}
  mkdir -p ${BUILDDIR}/isl-${ISL_VERSION}
  cd ${BUILDDIR}/isl-${ISL_VERSION}
  ../${SRCRELDIR}/isl-${ISL_VERSION}/configure --build=${HOST_NATIVE} --host=${HOST_NATIVE} --prefix=${INSTALLDIR} --disable-shared --with-gmp-prefix=${INSTALLDIR}
  make ${JOBS}
  make install
fi

if [ ${STEP2} ]; then
  echo "[Step 2.1] Build zlib..."
  cd ${DOWNLOADDIR}
  if [ ! -f zlib-${ZLIB_VERSION}.tar.xz ]; then
    curl -L -O http://zlib.net/zlib-${ZLIB_VERSION}.tar.xz
  fi
  tar xJf zlib-${ZLIB_VERSION}.tar.xz -C ${SRCDIR}
  cd ${SRCDIR}/zlib-${ZLIB_VERSION}
  rm -rf ${BUILDDIR}/zlib-${ZLIB_VERSION}
  mkdir -p ${BUILDDIR}/zlib-${ZLIB_VERSION}
  BINARY_PATH=${INSTALLDIR}/bin INCLUDE_PATH=${INSTALLDIR}/include LIBRARY_PATH=${INSTALLDIR}/lib 
  ../${SRCRELDIR}/zlib-${ZLIB_VERSION}/configure --static --prefix=${INSTALLDIR} 
  make ${JOBS}
  make install
  echo "[Step 2.2] Build libzip..."
  cd ${DOWNLOADDIR}
  if [ ! -f libzip-${LIBZIP_VERSION}.tar.xz ]; then
    curl -L -O https://nih.at/libzip/libzip-${LIBZIP_VERSION}.tar.xz
  fi
  tar xJf libzip-${LIBZIP_VERSION}.tar.xz -C ${SRCDIR}
  rm -rf ${BUILDDIR}/libzip-${LIBZIP_VERSION}
  mkdir -p ${BUILDDIR}/libzip-${LIBZIP_VERSION}
  cd ${BUILDDIR}/libzip-${LIBZIP_VERSION}
  CFLAGS='-DZIP_STATIC' ${SRCDIR}/libzip-${LIBZIP_VERSION}/configure --host=${HOST_NATIVE} --prefix=$INSTALLDIR --disable-shared --enable-static
  make ${JOBS} -C lib install

  echo "[Step 2.3] Build libelf..."
  cd ${DOWNLOADDIR}
  if [ ! -f libelf-${LIBELF_VERSION}.tar.gz ]; then
    curl -L -O http://www.mr511.de/software/libelf-${LIBELF_VERSION}.tar.gz
  fi
  tar xzf libelf-${LIBELF_VERSION}.tar.gz -C ${SRCDIR}
  cd ${SRCDIR}/libelf-${LIBELF_VERSION}
  patch -p1 < ${PATCHDIR}/libelf.patch
  rm -rf ${BUILDDIR}/libelf-${LIBELF_VERSION}
  mkdir -p ${BUILDDIR}/libelf-${LIBELF_VERSION}
  cd ${BUILDDIR}/libelf-${LIBELF_VERSION}
  ../${SRCRELDIR}/libelf-${LIBELF_VERSION}/configure --host=${HOST_NATIVE} --prefix=$INSTALLDIR
  make ${JOBS} install

  echo "[Step 2.4] Build jansson..."
  cd ${DOWNLOADDIR}
  if [ ! -f jansson-${JANSSON_VERSION}.tar.gz ]; then
    curl -L -o jansson-${JANSSON_VERSION}.tar.gz https://github.com/akheron/jansson/archive/v${JANSSON_VERSION}.tar.gz
  fi
  tar xzf jansson-${JANSSON_VERSION}.tar.gz -C ${SRCDIR}
  rm -rf ${BUILDDIR}/jansson-${JANSSON_VERSION}
  mkdir -p ${BUILDDIR}/jansson-${JANSSON_VERSION}
  cd ${BUILDDIR}/jansson-${JANSSON_VERSION}
  cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$INSTALLDIR -DCMAKE_BUILD_TYPE=Release -DJANSSON_BUILD_DOCS=OFF ${SRCDIR}/jansson-${JANSSON_VERSION}
  make ${JOBS} install
fi

if [ ${STEP3} ]; then
  echo "[Step 3] Build vita-toolchain..."
  if [ ! -d ${SRCDIR}/vita-toolchain/.git ]; then
    rm -rf ${SRCDIR}/vita-toolchain
    git clone https://github.com/vitasdk/vita-toolchain ${SRCDIR}/vita-toolchain
  else
    cd ${SRCDIR}/vita-toolchain
    git pull origin master
  fi
  rm -rf ${BUILDDIR}/vita-toolchain
  mkdir -p ${BUILDDIR}/vita-toolchain
  cd ${BUILDDIR}/vita-toolchain
  cmake -G"Unix Makefiles" -DCMAKE_C_FLAGS_RELEASE:STRING="-O3 -DNDEBUG -DZIP_STATIC" -DCMAKE_BUILD_TYPE=Release -DJansson_INCLUDE_DIR=$INSTALLDIR/include/ -DJansson_LIBRARY=$INSTALLDIR/lib/libjansson.a -Dlibelf_INCLUDE_DIR=$INSTALLDIR/include -Dlibelf_LIBRARY=$INSTALLDIR/lib/libelf.a -Dzlib_INCLUDE_DIR=$INSTALLDIR/include/ -Dzlib_LIBRARY=$INSTALLDIR/lib/libz.a -Dlibzip_INCLUDE_DIR=$INSTALLDIR/include/ -Dlibzip_CONFIG_INCLUDE_DIR=$INSTALLDIR/lib/libzip/include -Dlibzip_LIBRARY=$INSTALLDIR/lib/libzip.a -DCMAKE_INSTALL_PREFIX=${VITASDKROOT} -DDEFAULT_JSON=../share/db.json ${SRCDIR}/vita-toolchain
  make ${JOBS} install
fi

if [ ${STEP4} ]; then
  echo "[Step 4] Build binutils..."
  cd ${DOWNLOADDIR}
  if [ ! -f binutils-${BINUTILS_VERSION}.tar.bz2 ]; then
    curl -L -O http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.bz2
  fi
  tar xjf binutils-${BINUTILS_VERSION}.tar.bz2 -C ${SRCDIR}
  cd ${SRCDIR}/binutils-${BINUTILS_VERSION}
  patch -p1 < ${PATCHDIR}/binutils.patch
  #patch -p1 < ${PATCHDIR}/binutils-mingw.patch
  rm -rf ${BUILDDIR}/binutils-${BINUTILS_VERSION}
  mkdir -p ${BUILDDIR}/binutils-${BINUTILS_VERSION}
  cd ${BUILDDIR}/binutils-${BINUTILS_VERSION}
  ../${SRCRELDIR}/binutils-${BINUTILS_VERSION}/configure --host=${HOST_NATIVE} --build=${HOST_NATIVE} --target=arm-vita-eabi --prefix=${VITASDKROOT} --infodir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/info --mandir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/man --htmldir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/html --pdfdir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/pdf --disable-nls --disable-werror --disable-sim --disable-gdb --enable-interwork --enable-plugins --with-sysroot=${VITASDKROOT}/arm-vita-eabi --with-cloog=${INSTALLDIR} --with-isl=${INSTALLDIR} --disable-isl-version-check "--with-pkgversion=GNU Tools for ARM Embedded Processors [VitaSDK for macOS by bigboss]"
  make ${JOBS}
  make install
fi

export VITASDK=${VITASDKROOT}
export OLDPATH=${PATH}
export PATH=${VITASDK}/bin:${PATH}

if [ ${STEP5} ]; then
  echo "[Step 5] Build gcc first time..."
  cd ${DOWNLOADDIR}
  if [ ! -f gcc-${GCC_VERSION}.tar.bz2 ]; then
    curl -L -O http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.bz2
  fi
  tar xjf gcc-${GCC_VERSION}.tar.bz2 -C ${SRCDIR}
  cd ${SRCDIR}/gcc-${GCC_VERSION}
  patch -p1 < ${PATCHDIR}/gcc.patch
  #patch -p1 < ${PATCHDIR}/gcc-mingw.patch
  rm -rf ${BUILDDIR}/gcc-${GCC_VERSION}
  mkdir -p ${BUILDDIR}/gcc-${GCC_VERSION}
  cd ${BUILDDIR}/gcc-${GCC_VERSION}
  ../${SRCRELDIR}/gcc-${GCC_VERSION}/configure --host=${HOST_NATIVE} --build=${HOST_NATIVE} --target=arm-vita-eabi --prefix=${VITASDKROOT} --libexecdir=${VITASDKROOT}/lib --infodir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/info --mandir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/man --htmldir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/html --pdfdir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/pdf --enable-languages=c,c++ --disable-decimal-float --disable-libffi --disable-libgomp --disable-libmudflap --disable-libquadmath --disable-libssp --disable-libstdcxx-pch --disable-nls --disable-shared --disable-threads --disable-tls --with-newlib --without-headers --with-gnu-as --with-gnu-ld --with-python-dir=share/gcc-arm-vita-eabi --with-sysroot=${VITASDKROOT}/arm-vita-eabi --with-libiconv-prefix=${INSTALLDIR} --with-gmp=${INSTALLDIR} --with-mpfr=${INSTALLDIR} --with-mpc=${INSTALLDIR} --with-isl=${INSTALLDIR} --with-cloog=${INSTALLDIR} --disable-isl-version-check --with-libelf=${INSTALLDIR} "--with-host-libstdcxx= -Wl,-lstdc++,-lm"  "--with-pkgversion=GNU Tools for ARM Embedded Processors [VitaSDK for macOs by bigboss]" --disable-multilib --with-arch=armv7-a --with-tune=cortex-a9 --with-fpu=neon --with-float=hard --with-mode=thumb CXXFLAGS="-g -O2 -fbracket-depth=2048" CFLAGS_FOR_TARGET="-O2" CXXFLAGS_FOR_TARGET="-O2"
  make ${JOBS} all-gcc
  make install-gcc
fi

if [ ${STEP6} ]; then
  echo "[Step 6] Build vita-headers..."
  if [ ! -d ${SRCDIR}/vita-headers/.git ]; then
    rm -rf ${SRCDIR}/vita-headers
    git clone https://github.com/vitasdk/vita-headers ${SRCDIR}/vita-headers
  else
    cd ${SRCDIR}/vita-headers
    git pull origin master
  fi
  rm -rf ${BUILDDIR}/vita-headers
  mkdir -p ${BUILDDIR}/vita-headers
  cd ${BUILDDIR}/vita-headers
  vita-libs-gen ${SRCDIR}/vita-headers/db.json .
  make ARCH=${VITASDKROOT}/bin/arm-vita-eabi ${JOBS}
  cp *.a ${VITASDKROOT}/arm-vita-eabi/lib/
  cp -r ${SRCDIR}/vita-headers/include ${VITASDKROOT}/arm-vita-eabi/
  mkdir -p ${VITASDKROOT}/share
  cp ${SRCDIR}/vita-headers/db.json ${VITASDKROOT}/share
fi

if [ ${STEP7} ]; then
  echo "[Step 7] Build newlib..."
  if [ ! -d ${SRCDIR}/newlib/.git ]; then
    rm -rf ${SRCDIR}/newlib
    git clone https://github.com/vitasdk/newlib ${SRCDIR}/newlib
  else
    cd ${SRCDIR}/newlib
    git pull origin vita
  fi
  rm -rf ${BUILDDIR}/newlib
  mkdir -p ${BUILDDIR}/newlib
  cd ${BUILDDIR}/newlib
  ../${SRCRELDIR}/newlib/configure --host=${HOST_NATIVE} --build=${HOST_NATIVE} --target=arm-vita-eabi --prefix=${VITASDKROOT} --infodir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/info --mandir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/man --htmldir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/html --pdfdir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/pdf --enable-newlib-io-long-long --enable-newlib-register-fini --disable-newlib-supplied-syscalls --disable-nls
  make ${JOBS}
  make install
fi

if [ ${STEP8} ]; then
  echo "[Step 8] Build pthread..."
  if [ ! -d ${SRCDIR}/pthread-embedded/.git ]; then
    rm -rf ${SRCDIR}/pthread-embedded
    git clone https://github.com/vitasdk/pthread-embedded ${SRCDIR}/pthread-embedded
  else
    cd ${SRCDIR}/pthread-embedded
    git pull origin master
  fi
  rm -rf ${BUILDDIR}/pthread-embedded
  mkdir -p ${BUILDDIR}/pthread-embedded
  cd ${BUILDDIR}/pthread-embedded
  cp -R ../${SRCRELDIR}/pthread-embedded/* .
  cd platform/vita
  make ${JOBS} CFLAGS_FOR_TARGET='-g -O2 -ffunction-sections -fdata-sections'
  make install
fi

if [ ${STEP9} ]; then
  echo "[Step 9] Build gcc final..."
  if [ ! -d ${SRCDIR}/gcc-${GCC_VERSION} ]; then
    cd ${DOWNLOADDIR}
    if [ ! -f gcc-${GCC_VERSION}.tar.bz2 ]; then
      curl -L -O http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.bz2
    fi
    tar xjf gcc-${GCC_VERSION}.tar.bz2 -C ${SRCDIR}
    cd ${SRCDIR}/gcc-${GCC_VERSION}
    patch -p1 < ${PATCHDIR}/gcc.patch
    #patch -p1 < ${PATCHDIR}/gcc-mingw.patch
  fi
  pushd ${VITASDKROOT}/arm-vita-eabi
  mkdir -p ./usr
  cp -rf include lib usr/
  popd
  rm -rf ${BUILDDIR}/gcc-${GCC_VERSION}-final
  mkdir -p ${BUILDDIR}/gcc-${GCC_VERSION}-final
  cd ${BUILDDIR}/gcc-${GCC_VERSION}-final
  ../${SRCRELDIR}/gcc-${GCC_VERSION}/configure --host=${HOST_NATIVE} --build=${HOST_NATIVE} --target=arm-vita-eabi --prefix=${VITASDKROOT} --libexecdir=${VITASDKROOT}/lib --infodir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/info --mandir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/man --htmldir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/html --pdfdir=${VITASDKROOT}/share/doc/gcc-arm-vita-eabi/pdf --enable-languages=c,c++ --enable-plugins --enable-threads=posix --disable-decimal-float --disable-libffi --disable-libgomp --disable-libmudflap --disable-libquadmath --disable-libssp --disable-libstdcxx-pch --disable-libstdcxx-verbose --disable-nls --disable-shared --disable-tls --with-gnu-as --with-gnu-ld --with-newlib --with-headers=yes --with-python-dir=share/gcc-arm-vita-eabi --with-sysroot=${VITASDKROOT}/arm-vita-eabi --with-libiconv-prefix=${INSTALLDIR} --with-gmp=${INSTALLDIR} --with-mpfr=${INSTALLDIR} --with-mpc=${INSTALLDIR} --with-isl=${INSTALLDIR} --with-cloog=${INSTALLDIR} --disable-isl-version-check --with-libelf=${INSTALLDIR}  "--with-host-libstdcxx= -Wl,-lstdc++,-lm" "--with-pkgversion=GNU Tools for ARM Embedded Processors [VitaSDK for macOS by bigboss]" --disable-multilib --with-arch=armv7-a --with-tune=cortex-a9 --with-fpu=neon --with-float=hard --with-mode=thumb CXXFLAGS="-g -O2 -fbracket-depth=2048" CFLAGS_FOR_TARGET="-O2" CXXFLAGS_FOR_TARGET="-O2"
  make ${JOBS} INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
  make install

  pushd ${VITASDKROOT}
  rm -rf bin/arm-vita-eabi-gccbug
  LIBIBERTY_LIBRARIES=`find ${VITASDKROOT}/arm-vita-eabi/lib -name libiberty.a`
  for libiberty_lib in $LIBIBERTY_LIBRARIES ; do
      rm -rf $libiberty_lib
  done
  rm -rf ./lib/libiberty.a
  rmdir include
  rm -rf ./arm-vita-eabi/usr
  popd
fi

if [ ${STEP10} ]; then
  echo "[Step 10] Strip binaries..."
  
  STRIP_BINARIES=`find ${VITASDKROOT}/bin/ -name arm-vita-eabi-\*`
  for bin in $STRIP_BINARIES ; do
          strip_binary strip $bin
      done

      STRIP_BINARIES=`find ${VITASDKROOT}/arm-vita-eabi/bin/ -maxdepth 1 -mindepth 1 -name \*`
      for bin in $STRIP_BINARIES ; do
          strip_binary strip $bin
      done

      STRIP_BINARIES=`find ${VITASDKROOT}/lib/gcc/arm-vita-eabi/${GCC_VERSION}/ -maxdepth 1 -name \* -perm +111 -and ! -type d`
      for bin in $STRIP_BINARIES ; do
          strip_binary strip $bin
  done
  

  find ${VITASDKROOT} -name '*.la' -exec rm '{}' ';'

  for target_lib in `find ${VITASDKROOT}/arm-vita-eabi/lib -name \*.a` ; do
      arm-vita-eabi-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc $target_lib || true
  done

  for target_obj in `find ${VITASDKROOT}/arm-vita-eabi/lib -name \*.o` ; do
      arm-vita-eabi-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc $target_obj || true
  done

  for target_lib in `find ${VITASDKROOT}/lib/gcc/arm-vita-eabi/${GCC_VERSION} -name \*.a` ; do
      arm-vita-eabi-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc $target_lib || true
  done

  for target_obj in `find ${VITASDKROOT}/lib/gcc/arm-vita-eabi/${GCC_VERSION} -name \*.o` ; do
      arm-vita-eabi-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc $target_obj || true
  done
fi

export PATH=${OLDPATH}
export -n OLDPATH
echo "[DONE] Everything is OK!"
