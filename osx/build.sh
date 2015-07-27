set -e

ROOT_SRC=`pwd`/src
ROOT_LIB=`pwd`/lib
BUILD_OUTPUT=`pwd`/output

test -e ${BUILD_OUTPUT}/Ricochet.app && rm -r ${BUILD_OUTPUT}/Ricochet.app
test -e ${BUILD_OUTPUT}/ricochet-unstripped && rm ${BUILD_OUTPUT}/ricochet-unstripped
test -e ${BUILD_OUTPUT}/Ricochet*.dmg && rm ${BUILD_OUTPUT}/Ricochet*.dmg

cd $ROOT_SRC

# Ricochet
test -e ricochet || git clone https://github.com/ricochet-im/ricochet.git
cd ricochet

RICOCHET_VERSION=`git describe --tags HEAD`

test -e build && rm -r build
mkdir build
cd build

export PKG_CONFIG_PATH=${ROOT_LIB}/protobuf/lib/pkgconfig:${PKG_CONFIG_PATH}
export PATH=${ROOT_LIB}/qt5/bin/:${ROOT_LIB}/protobuf/bin/:${PATH}
qmake CONFIG+=release OPENSSLDIR="${ROOT_LIB}/openssl/" ..
make ${MAKEOPTS}

cp ricochet.app/Contents/MacOS/ricochet ${BUILD_OUTPUT}/ricochet-unstripped
cp ${BUILD_OUTPUT}/tor ricochet.app/Contents/MacOS
strip ricochet.app/Contents/MacOS/*

mv ricochet.app Ricochet.app
${ROOT_LIB}/qt5/bin/macdeployqt Ricochet.app -qmldir=../src/ui/qml

if [ ! -z "$CODESIGN_ID" ]; then
    codesign --verbose --sign "$CODESIGN_ID" --deep Ricochet.app
    codesign -vvvv -d Ricochet.app
fi

cp -R Ricochet.app ${BUILD_OUTPUT}/
hdiutil create Ricochet.dmg -srcfolder Ricochet.app -format UDZO -volname Ricochet
cp Ricochet.dmg ${BUILD_OUTPUT}/Ricochet-${RICOCHET_VERSION}.dmg

cd ..
echo "---------------------"
ls -la ${BUILD_OUTPUT}/
spctl -vvvv --assess --type execute ${BUILD_OUTPUT}/Ricochet.app
echo "build: done"
