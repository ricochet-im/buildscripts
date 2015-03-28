# Run in the same environment where setup.sh was used to build everything

set -e

ROOT_SRC=`pwd`/src
ROOT_LIB=`pwd`/lib

QT_TAG=v5.4.1
OPENSSL_TAG=OpenSSL_1_0_1m
TOR_BRANCH=origin/release-0.2.6
PROTOBUF_TAG=v2.6.1

test -e ${ROOT_LIB}/qt5 && rm -r ${ROOT_LIB}/qt5
test -e ${ROOT_LIB}/openssl && rm -r ${ROOT_LIB}/openssl
test -e ${ROOT_LIB}/protobuf} && rm -r ${ROOT_LIB}/protobuf

cd $ROOT_SRC

# Build Qt
cd qt5
git fetch
git checkout ${QT_TAG}
git submodule update
./configure -opensource -confirm-license -static -no-qml-debug -qt-zlib -qt-libpng -qt-libjpeg -qt-freetype -no-nis -no-openssl -qt-pcre -qt-xcb -qt-xkbcommon -nomake tests -nomake examples -no-cups -prefix "${ROOT_LIB}/qt5/"
time make -j9
make install
cd ..

# Build Openssl
cd openssl
git fetch
git checkout ${OPENSSL_TAG}
# 32bit may need to use ./Configure and linux-generic32 if setarch isn't handled properly
./config no-shared no-zlib --prefix="${ROOT_LIB}/openssl/" -fPIC
make
make install
cd ..

# Build Tor
cd tor
git fetch
git checkout ${TOR_BRANCH}
./autogen.sh
CFLAGS=-fPIC ./configure --with-openssl-dir="${ROOT_LIB}/openssl/" --enable-static-libevent --enable-static-openssl --with-libevent-dir=/usr/lib/`gcc -print-multiarch`/ --disable-asciidoc
make -j9
cd ..

# Build Protobuf
cd protobuf
git fetch
git checkout ${PROTOBUF_TAG}
./autogen.sh
./configure --prefix="${ROOT_LIB}/protobuf/" --disable-shared --without-zlib --with-pic
make -j9
make install
cd ..

# Build Ricochet
cd ricochet
git pull
RICOCHET_VERSION="`git describe --tags HEAD`"
cat > .packagingrc << EOF
export MAKEOPTS=-j9
export PATH=${ROOT_LIB}/qt5/bin/:${ROOT_LIB}/protobuf/bin/:$PATH
export TOR_BINARY=${ROOT_SRC}/tor/src/or/tor
export QMAKEOPTS='OPENSSLDIR="${ROOT_LIB}/openssl/"'
export PKG_CONFIG_PATH=${ROOT_LIB}/protobuf/lib/pkgconfig
export VERSION=${RICOCHET_VERSION}
EOF
./packaging/linux-static/release.sh

