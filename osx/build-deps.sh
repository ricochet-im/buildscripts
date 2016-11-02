set -e

ROOT_SRC=`pwd`/src
ROOT_LIB=`pwd`/lib
BUILD_OUTPUT=`pwd`/output
test -e ${ROOT_SRC}
test -e ${ROOT_LIB} && rm -r ${ROOT_LIB}
mkdir ${ROOT_LIB}
test -e ${BUILD_OUTPUT} && rm -r ${BUILD_OUTPUT}
mkdir ${BUILD_OUTPUT}

# Build dependencies
git submodule update --init
cd $ROOT_SRC

# Qt
cd qt5
git submodule update --init qtbase qtdeclarative qtgraphicaleffects qtimageformats qtquickcontrols qtsvg qtmacextras qttools qtmultimedia
git submodule foreach git clean -dfx .
git submodule foreach git reset --hard
./configure -opensource -confirm-license -release \
    -no-qml-debug -no-dbus -no-openssl -no-cups -no-nis \
    -qt-zlib -qt-libpng -qt-libjpeg -qt-freetype -qt-pcre \
    -nomake tests -nomake examples \
    -prefix "${ROOT_LIB}/qt5/"
make ${MAKEOPTS}
make install
cd ..

# Qt Declarative 2D Renderer
cd qtdeclarative-render2d
git clean -dfx .
git reset --hard
"${ROOT_LIB}/qt5/bin/qmake"
make ${MAKEOPTS}
make install
cd ..

# Openssl
cd openssl
git clean -dfx .
git reset --hard
./Configure no-shared no-zlib --prefix="${ROOT_LIB}/openssl/" -fPIC -mmacosx-version-min=10.7 darwin64-x86_64-cc
make -j1
make install
cd ..

# Libevent
cd libevent
git clean -dfx .
git reset --hard
./autogen.sh
./configure --prefix="${ROOT_LIB}/libevent" --disable-openssl
make ${MAKEOPTS}
make install
cd ..
fi

# Tor
cd tor
git clean -dfx .
git reset --hard
./autogen.sh
CFLAGS="-fPIC -mmacosx-version-min=10.7" ./configure --prefix="${ROOT_LIB}/tor" --with-openssl-dir="${ROOT_LIB}/openssl/" --with-libevent-dir="${ROOT_LIB}/libevent/" --enable-static-openssl --enable-static-libevent --disable-asciidoc
make ${MAKEOPTS}
make install
cp ${ROOT_LIB}/tor/bin/tor ${BUILD_OUTPUT}/
cd ..

# Protobuf
cd protobuf
git clean -dfx .
git reset --hard

# Protobuf will rudely fetch this over HTTP if it isn't present..
if [ ! -e gtest ]; then
	git clone https://github.com/google/googletest.git gtest
	cd gtest
	git checkout release-1.5.0
	cd ..
fi

./autogen.sh
CXX=clang++ CXXFLAGS="-mmacosx-version-min=10.7 -stdlib=libc++" ./configure --prefix="${ROOT_LIB}/protobuf/" --disable-shared --without-zlib --with-pic
make ${MAKEOPTS}
make install
cd ..

cd ..
echo "build-deps: done"
