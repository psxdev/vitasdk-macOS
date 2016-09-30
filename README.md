# vitasdk-macOS
PlayStation Vita development under macOS Sierra
===============================================

==============
 Why use macOS?
==============

I have been developing homebrew stuff for PlayStation platform since last 15 years and since my first Apple laptop with Osx Panther (2003) it has been my development platform. I don't like open a virtual machine with linux or windows to develop, i like more use all directily in my Mac, so for me it is the best option.


==============
  Steps 
==============

 1) Install macOS Sierra. 

I made a clean installation because i like more a fresh install instead of upgrade. I was in Os X Maverick so first i always make a copy of my system in external disk with carbon copy cloner and then check that i can boot from it before install new operating system. You can follow many guides on internet to do it.

 2) Install Xcode
 
Go to apple appstore download and install Xcode (Version 8)

 3) Install Xcode command line tools
 
Go to apple developer site and download and install Command Line Tools (macOS 10.12) for Xcode 8 package

 4) Install some misc tools that i use often
 
 * XQuartz from https://www.xquartz.org/index.html
 * TextMate from https://macromates.com/
 * iTerm from https://www.iterm2.com/
 * Enable root account (Open Directory Utility in drop down "Edit Menu" enable root user and it will ask you to set a password for root user)
 
5) Install macports (other people use homebrew instead)
 
 Go to https://www.macports.org/install.php and follow steps described for macOS Sierra
 
 
 ```
 sudo port -v selfupdate

 sudo port install autoconf automake bison flex texinfo ncurses wget libelf zlib libtool git gmp openssl mpfr libmpc unrar subversion bzip2 cmake pkgconfig go python34
 
 ```
 
 6) Create base directory for vitadev and clone repositories
 
 ```
 cd /usr/local
 sudo mkdir -p vitadev/git
 sudo chown -R youruser:staff vitadev
 cd vitadev/git
 git clone http://github.com/xerpi/libvita2d
 git clone http://github.com/xerpi/libftpvita
 git clone http://github.com/xerpi/vita_portlibs
 git clone http://github.com/frangarcj/psplib4vita
 git clone http://github.com/psxdev/debugnet
 git clone http://github.com/psxdev/psp2link
 git clone http://github.com/psxdev/psp2client
 git clone http://github.com/psxdev/vitasdk-macOS
 ```
 
 7) Build toolchain and sdk 
 
 ```
 cd vitasdk-macOS
 ./build_macOS.sh
 ```
 
 8) Install toolchain and sdk 
 
 ```
 cd vitasdk
 cp -r bin /usr/local/vitadev
 cp -r arm-vita-eabi /usr/local/vitadev
 cp -r lib /usr/local/vitadev
 cp -r share /usr/local/vitadev
 ```
 
 9) Prepare profile with environment 
 
 I use this script vitadev.sh in /usr/local/vitadev customize your own 
 
 ```
 cat /usr/local/vitadev.sh
 export VITADEV=/usr/local/vitadev
 export VITASDK=/usr/local/vitadev
 export PATH=$VITASDK/bin:$PATH
 export PSVITAIP=192.168.1.24
 ```
 
 10) Development session :)
 
 ```
 cd /usr/local/vitadev
 . ./vitadev.sh
 cd git
 cd vita_portlibs
 make
 cd ../libvita2d/libvita2d
 make
 make install
 cd ../../libftpvita/libftpvita
 make
 make install
 cd ../../psplib4vita/psplib
 make 
 make install
 cd ../../debugnet/libdebugnet
 make
 make install
 cd ../../psp2link/libpsp2link
 make
 make install
 ```
 
 11) Ready to have a lot of fun :)
 
==============
  Versions of software downloaded internally by build proccess 
============== 
* http://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz
* http://ftp.gnu.org/gnu/gmp/gmp-6.1.1.tar.xz
* http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.4.tar.xz
* http://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
* git://sourceware.org/git/binutils-gdb.git
* http://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.bz2
* http://www.mr511.de/software/libelf-1.2.8.tar.gz
* http://isl.gforge.inria.fr/isl-0.17.1.tar.xz
* http://nih.at/libzip/libzip-1.1.3.tar.xz
* http://zlib.net/zlib-1.2.8.tar.xz
* http://github.com/akheron/jansson/archive/v2.8.tar.gz
* http://github.com/vitasdk/vita-headers
* http://github.com/vitasdk/newlib
* http://github.com/vitasdk/pthread-embedded
* http://github.com/vitasdk/vita-toolchain
 
 
==============
  Credits 
==============
 
 * Based in soarqin good work at https://github.com/soarqin/vitasdk-msys2
 * Previous work for osx at https://github.com/psxdev/vitasdk-buildscripts 
 
