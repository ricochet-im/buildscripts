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
git submodule update --init src/{openssl,tor,protobuf}
cd $ROOT_SRC

# Openssl
cd openssl
# CRLF can break a perl script used by openssl's build; reset core.autocrlf on this repo
if [ "`git config core.autocrlf`" != "false" ]; then
	echo "Fixing core.autocrlf on OpenSSL repository"
	git config core.autocrlf false
	git rm --cached -r .
fi
git clean -dfx .
git reset --hard
./config no-shared no-zlib --prefix="${ROOT_LIB}/openssl/"
make -j1
make install
cd ..

# Tor
cd tor
git clean -dfx .
git reset --hard
./autogen.sh
LIBS+=-lcrypt32 ./configure --prefix="${ROOT_LIB}/tor" --with-openssl-dir="${ROOT_LIB}/openssl/" --with-libevent-dir=`pkg-config --variable=libdir libevent` --with-zlib-dir=`pkg-config --variable=libdir zlib` --enable-static-tor --disable-asciidoc
make ${MAKEOPTS}
make install
cp ${ROOT_LIB}/tor/bin/tor.exe ${BUILD_OUTPUT}/
cd ..

# Protobuf
cd protobuf
git clean -dfx .
git reset --hard
./autogen.sh
./configure --prefix="${ROOT_LIB}/protobuf/" --disable-shared --without-zlib
make ${MAKEOPTS}
make install
cd ..

cd ..
echo "build-deps: done"

