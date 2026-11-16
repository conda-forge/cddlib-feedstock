#!/bin/bash
if [[ "${target_platform}" != win-* ]]; then
  # Get an updated config.sub and config.guess
  cp $BUILD_PREFIX/share/libtool/build-aux/config.* .
fi

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O2 $CFLAGS"

# Pick up patches to configure.ac
autoreconf -ivf

chmod +x configure
./configure --prefix="$PREFIX" --disable-static

if [[ "${target_platform}" == win-* ]]; then
  patch_libtool
  # Pass "-Xclang --dependent-lib=-lgmp" through in libtool
  sed -i 's@|-Xclang|@|-Xclang|--dependent-lib=*|@g' libtool
fi

make

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make check
fi

make install

if [[ "${target_platform}" == win-* ]]; then
  # Install .lib without the .dll.lib suffix
  for lib in cdd cddgmp; do
    mv "$PREFIX/lib/$lib.dll.lib" "$PREFIX/lib/$lib.lib"
  done
fi

