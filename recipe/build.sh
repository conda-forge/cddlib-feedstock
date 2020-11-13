#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O2 $CFLAGS"

chmod +x configure
./configure --prefix="$PREFIX"

make
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi
make install
