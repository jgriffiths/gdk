#! /usr/bin/env bash
set -e

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

COMPILER=${COMPILER:-clang}
SRC_ROOT=${SRC_ROOT:-${PWD}}
BLD_ROOT=${BLD_ROOT:-${SRC_ROOT}/build-${COMPILER}}
DEBUG=${DEBUG:-""}

[ -f /proc/cpuinfo ] && JOBS=${JOBS:-$(cat /proc/cpuinfo | grep ^processor | wc -l)}
JOBS=${JOBS:-4}

mkdir -p ${BLD_ROOT}

export CC=${COMPILER}
export CFLAGS="-DPIC -fPIC"

# boost
boost_tarball="boost_1_72_0.tar.gz"
boost_sha256="c66e88d5786f2ca4dbebb14e06b566fb642a1a6947ad8cc9091f9f445134143f"
if [ ! -f ${SRC_ROOT}/$boost_tarball ]; then
    wget https://dl.bintray.com/boostorg/release/1.72.0/source/$boost_tarball
fi
boost_dl_sha256=$(shasum -a 256 $boost_tarball | cut -d' ' -f1)
if [ "$boost_dl_sha256" != "$boost_sha256" ]; then
    echo "boost tarball corrupted"
    exit 1
fi
pushd ${BLD_ROOT}
tar xzf ${SRC_ROOT}/$boost_tarball
cd boost_*
./bootstrap.sh --prefix="${BLD_ROOT}" \
    --with-libraries=chrono,date_time,log,system,thread \
    --with-toolset=${COMPILER}
./b2 -d0 -j${JOBS} --with-chrono --with-date_time --with-log --with-thread \
    --with-system --no-cmake-config link=static release install
rm -r ${BLD_ROOT}/boost_*
popd

# zlib
pushd ${SRC_ROOT}/src/zlib
./configure --prefix="${BLD_ROOT}" --static --const
make -j${JOBS}
make install
git checkout Makefile zconf.h
popd

# openssl
pushd ${SRC_ROOT}/src/openssl
[ -f util/shlib_wrap.sh ] && make clean >/dev/null 2>&1
./config --prefix="${BLD_ROOT}" \
    enable-ec_nistp_64_gcc_128 no-gost no-shared no-dso no-ssl2 no-ssl3 \
    no-idea no-dtls no-dtls1 no-weak-ssl-ciphers no-comp no-err no-psk \
    no-srp -fvisibility=hidden
make depend
make -j${JOBS} >/dev/null
make install_sw
popd

# wally
pushd ${SRC_ROOT}/src/libwally-core
./tools/autogen.sh
CC=${COMPILER} ./configure --prefix="${BLD_ROOT}" --with-pic --enable-static --disable-shared \
    --enable-elements --enable-ecmult-static-precomputation --disable-tests
make -j${JOBS}
make install
popd

# libevent
pushd ${SRC_ROOT}/src/libevent
./autogen.sh
CC=${COMPILER} ./configure --prefix="${BLD_ROOT}" --with-pic --enable-static --disable-shared \
    --disable-openssl --disable-samples --disable-libevent-regress \
    --disable-debug-mode --disable-dependency-tracking
make -j${JOBS}
make install
popd

# tor
#FIXME: enable zstd for tor compression
pushd ${SRC_ROOT}/src/tor
./autogen.sh
CC=${COMPILER} ./configure --prefix=${BLD_ROOT} --enable-pic --enable-static-openssl \
    --enable-static-libevent --enable-static-zlib \
    --with-openssl-dir=${BLD_ROOT} --with-libevent-dir=${BLD_ROOT} \
    --with-zlib-dir=${BLD_ROOT} --disable-system-torrc --disable-asciidoc \
    --disable-systemd --disable-zstd --disable-lzma --disable-largefile \
    --disable-unittests --disable-tool-name-check --disable-module-dirauth \
    --disable-rust --disable-manpage --disable-html-manual --disable-asciidoc
make -j${JOBS}
make install
popd
