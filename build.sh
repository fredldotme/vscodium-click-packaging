#!/bin/bash

set -e

dlarch="$1"
if [ "$1" == "amd64" ]; then
    dlarch="x64"
fi

frameworkver="$2"
if [ "$2" == "focal" ]; then
    frameworkver="20.04"
else
    frameworkver="16.04.5"
fi

CLICK_ARCH=$(dpkg-architecture -qDEB_HOST_ARCH)
CLICK_FRAMEWORK=ubuntu-sdk-$frameworkver

pkgver=1.68.1
srcdir=$ROOT
pkgdir=$INSTALL_DIR
pkgfile=VSCodium-linux-$dlarch-$pkgver.tar.gz

if [ -f "$pkgfile" ]; then
    rm "$pkgfile"
fi

mkdir -p $pkgdir

# Various common environment variables
export PKG_CONFIG_PATH=$pkgdir/lib/pkgconfig:$pkgdir/share/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$pkgdir/lib:$LD_LIBRARY_PATH

# Build wayland-protocols
if [ ! -f $pkgdir/.wayland-protocols-done ]; then
    OLD_PWD=$(pwd)
    cd $srcdir/3rdparty/wayland-protocols
    ./autogen.sh --prefix=$pkgdir
    make -j$(nproc --all)
    make install
    touch $pkgdir/.wayland-protocols-done
    cd $OLD_PWD
fi

# Build glib
if [ ! -f $pkgdir/.glib-done ]; then
    OLD_PWD=$(pwd)
    cd $srcdir/3rdparty/glib
    ./autogen.sh  --prefix=$pkgdir
    make -j$(nproc --all)
    make install
    touch $pkgdir/.glib-done
    cd $OLD_PWD
fi

# Build gtk
if [ ! -f $pkgdir/.gtk-done ]; then
    OLD_PWD=$(pwd)
    cd $srcdir/3rdparty/gtk
    ./autogen.sh --prefix=$pkgdir --disable-x11-backend --enable-wayland-backend
    make -j$(nproc --all)
    make install
    touch $pkgdir/.gtk-done
    cd $OLD_PWD
fi

# Build gtk-nocsd
if [ ! -f $pkgdir/.gtk-nocsd-done ]; then
    OLD_PWD=$(pwd)
    cd $srcdir/3rdparty/gtk-nocsd
    make -j$(nproc --all)
    make install prefix=$pkgdir
    touch $pkgdir/.gtk-nocsd-done
    cd $OLD_PWD
fi

# Pull VSCodium

wget https://github.com/VSCodium/vscodium/releases/download/$pkgver/$pkgfile
tar xvf ./VSCodium-linux-$dlarch-$pkgver.tar.gz -C $pkgdir

cp $ROOT/manifest.json $pkgdir/
sed -i "s/@CLICK_ARCH@/$CLICK_ARCH/g" $pkgdir/manifest.json
sed -i "s/@CLICK_FRAMEWORK@/$CLICK_FRAMEWORK/g" $pkgdir/manifest.json
cp $ROOT/codium.apparmor $pkgdir/
cp $ROOT/codium.desktop $pkgdir/
cp $ROOT/codium.wrapper $pkgdir/
chmod a+x $pkgdir/codium.wrapper
chown root $pkgdir/chrome-sandbox
chmod 4755 $pkgdir/chrome-sandbox

exit 0
