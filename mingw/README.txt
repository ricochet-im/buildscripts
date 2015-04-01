Install the Qt SDK. Select the MinGW build.
Install Inno Setup 5
Install msys2 according to its directions; remember the pacman commands for updating it post-install.

Run mingw32_shell.bat, and install dependencies with:

pacman -S make perl autoconf automake pkg-config tar libtool
pacman -S mingw32/mingw-w64-i686-gcc mingw32/mingw-w64-i686-libevent mingw32/mingw-w64-i686-zlib

Remember to keep these packages up to date.

Before running build.sh, you need to modify PATH to include qmake and iscc (inno setup). For example:

export PATH=/c/Qt/5.4/mingw491_32/bin:/c/Program\ Files\ \(x86\)/Inno\ Setup\ 5/:$PATH