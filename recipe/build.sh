#!/bin/bash
if [[ "${target_platform}" != win-* ]]; then
  # Get an updated config.sub and config.guess
  cp $BUILD_PREFIX/share/libtool/build-aux/config.* .
fi

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O2 $CFLAGS"

chmod +x configure
./configure --prefix="$PREFIX" --disable-static

if [[ "${target_platform}" == win-* ]]; then
  patch_libtool
fi

make
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi
make install

if [[ "${target_platform}" == win-* ]]; then
  # autotools_clang_conda only renames ${PKG_NAME}.dll.lib, so do it for our libraries
  for lib in cdd cddgmp; do
    mv "$PREFIX/lib/lib$lib.dll.lib" "$PREFIX/lib/$lib.lib"
  done
fi
