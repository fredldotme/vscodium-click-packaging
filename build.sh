#!/bin/bash

set -e

dlarch="$1"
if [ "$1" == "amd64" ]; then
    dlarch="x64"
fi

CLICK_ARCH=$(dpkg-architecture -qDEB_HOST_ARCH)
CLICK_FRAMEWORK=ubuntu-sdk-16.04.5

pkgver=1.68.1
srcdir=$ROOT
pkgdir=$INSTALL_DIR
pkgfile=VSCodium-linux-$dlarch-$pkgver.tar.gz

if [ -f "$pkgfile" ]; then
    rm "$pkgfile"
fi

mkdir -p $pkgdir

# Build GTK
OLD_PWD=$(pwd)
cd $srcdir/3rdparty/gtk
./autogen.sh
./configure --prefix=$pkgdir
make -j$(nproc --all)
make install
cd $OLD_PWD

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
