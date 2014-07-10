# Run inside a new, Debian-based container to set up a build environment the first time

set -e

ROOT_SRC=`pwd`/src
ROOT_LIB=`pwd`/lib

apt-get install -y git build-essential python curl vim

# Qt
apt-get install -y "^libxcb.*" libx11-xcb-dev libglu1-mesa-dev libxrender-dev
apt-get install -y libfontconfig1-dev libglu1-mesa-dev libxrender-dev xkb-data

# Tor
apt-get install -y autoconf automake libevent-dev

# Setup
mkdir -p $ROOT_SRC
mkdir -p $ROOT_LIB
cd $ROOT_SRC

git clone https://git.gitorious.org/qt/qt5.git qt5
cd qt5
./init-repository --no-webkit
cd ..

git clone https://github.com/openssl/openssl.git
git clone https://git.torproject.org/tor.git
git clone https://github.com/ricochet-im/ricochet

