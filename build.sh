#!/bin/bash

sed -e

rm *.tar.gz

pkgname=vscodium
pkgver=1.65.0
srcdir=$ROOT/build/aarch64-linux-gnu/app
pkgdir=$srcdir/install
mkdir -p $srcdir $pkgdir

wget https://github.com/VSCodium/vscodium/releases/download/$pkgver/VSCodium-linux-$1-$pkgver.tar.gz
mkdir -p $srcdir/vscodium/VSCodium-linux-$1-$pkgver
tar xvf ./VSCodium-linux-$1-$pkgver.tar.gz -C $pkgdir

CLICK_ARCH=$(dpkg-architecture -qDEB_HOST_ARCH)
CLICK_FRAMEWORK=ubuntu-sdk-16.04.5

cp $ROOT/manifest.json $pkgdir/
sed -i "s/@CLICK_ARCH@/$CLICK_ARCH/g" $pkgdir/manifest.json
sed -i "s/@CLICK_FRAMEWORK@/$CLICK_FRAMEWORK/g" $pkgdir/manifest.json
cp $ROOT/codium.apparmor $pkgdir/
cp $ROOT/codium.desktop $pkgdir/

exit 0
