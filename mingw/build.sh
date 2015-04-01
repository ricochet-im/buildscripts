# PATH must contain qmake, iscc (inno setup)

# Configuration and package versions
OPENSSL_TAG=OpenSSL_1_0_1m
TOR_TAG=tor-0.2.6.6
PROTOBUF_TAG=v2.6.1
MAKEOPTS=-j9

set -e
ROOT_SRC=`pwd`/src
ROOT_LIB=`pwd`/lib
BUILD_OUTPUT=`pwd`/output
test -e ${ROOT_SRC} || mkdir src
test -e ${ROOT_LIB} && rm -r ${ROOT_LIB}
mkdir ${ROOT_LIB}
test -e ${BUILD_OUTPUT} && rm -r ${BUILD_OUTPUT}
mkdir ${BUILD_OUTPUT}

# Build dependencies
cd $ROOT_SRC

# Openssl
if [ ! -e openssl ]; then
	git clone --no-checkout https://github.com/openssl/openssl.git
	cd openssl
	# CRLF can break a perl script used by openssl's build
	git config core.autocrlf false
	git reset --hard
	cd ..
fi

cd openssl
git fetch
git clean -dfx .
git reset --hard
git checkout ${OPENSSL_TAG}
./config no-shared no-zlib --prefix="${ROOT_LIB}/openssl/"
make
make install
cd ..

# Tor
test -e tor || git clone https://git.torproject.org/tor.git
cd tor
git fetch
git clean -dfx .
git reset --hard
git checkout ${TOR_TAG}
./autogen.sh
LIBS+=-lcrypt32 ./configure --prefix="${ROOT_LIB}/tor" --with-openssl-dir="${ROOT_LIB}/openssl/" --with-libevent-dir=`pkg-config --variable=libdir libevent` --with-zlib-dir=`pkg-config --variable=libdir zlib` --enable-static-tor --disable-asciidoc
make
make install
cp ${ROOT_LIB}/tor/bin/tor.exe ${BUILD_OUTPUT}/
cd ..

# Protobuf
test -e protobuf || git clone https://github.com/google/protobuf.git
cd protobuf
git fetch
git clean -dfx .
git reset --hard
git checkout ${PROTOBUF_TAG}
./autogen.sh
./configure --prefix="${ROOT_LIB}/protobuf/" --disable-shared --without-zlib
make
make install
cd ..

# Ricochet
test -e ricochet || git clone https://github.com/ricochet-im/ricochet.git
cd ricochet
git pull
git clean -dfx .

mkdir build
cd build
qmake CONFIG+=release OPENSSLDIR="${ROOT_LIB}/openssl/" PROTOBUFDIR="${ROOT_LIB}/protobuf/" DEFINES+=PROTOCOL_NEW ..
make
cp release/ricochet.exe ${BUILD_OUTPUT}/

mkdir installer
cd installer
cp ${BUILD_OUTPUT}/ricochet.exe .
cp ${BUILD_OUTPUT}/tor.exe .
windeployqt --qmldir ../../src/ui/qml --dir Qt ricochet.exe 
test -e Qt/qmltooling && rm -r Qt/qmltooling
cp ../../packaging/installer/* .
iscc installer.iss
cp Output/Ricochet.exe ${BUILD_OUTPUT}/setup.exe
cd ../../..

echo "---------------------"
ls -la ${BUILD_OUTPUT}/