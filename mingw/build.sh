set -e

# Ensure PATH is set correctly
which qmake >/dev/null
which iscc >/dev/null

ROOT_SRC=`pwd`/src
ROOT_LIB=`pwd`/lib
BUILD_OUTPUT=`pwd`/output

cd src

# Ricochet
test -e ricochet || git clone https://github.com/ricochet-im/ricochet.git
cd ricochet

test -e build && rm -r build
mkdir build
cd build
qmake CONFIG+=release OPENSSLDIR="${ROOT_LIB}/openssl/" PROTOBUFDIR="${ROOT_LIB}/protobuf/" ..
make ${MAKEOPTS}
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
echo "build: done"
