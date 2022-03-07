#!/bin/bash

sed -e

rm PKGBUILD* || true
rm *.tar.gz

wget https://raw.githubusercontent.com/KaOS-Community-Packages/vscode/master/PKGBUILD
sed -i "s/^arch=('x86_64')//g" PKGBUILD
sed -i "s/ln -s/#ln -s/g" PKGBUILD
sed -i "s/VSCode-linux-x64/VSCode-linux-$1/g" PKGBUILD
source PKGBUILD

srcdir=$ROOT/build/aarch64-linux-gnu/app
pkgdir=$srcdir/install
mkdir -p $srcdir $pkgdir

wget https://az764295.vo.msecnd.net/stable/b5205cc8eb4fbaa726835538cd82372cc0222d43/code-stable-$1-1646219865.tar.gz
tar xvf ./code-stable-$1-1646219865.tar.gz -C $srcdir

package

CLICK_ARCH=$(dpkg-architecture -qDEB_HOST_ARCH)
CLICK_FRAMEWORK=ubuntu-sdk-16.04.5

cp $ROOT/manifest.json $pkgdir/
sed -i "s/@CLICK_ARCH@/$CLICK_ARCH/g" $pkgdir/manifest.json
sed -i "s/@CLICK_FRAMEWORK@/$CLICK_FRAMEWORK/g" $pkgdir/manifest.json
cp $ROOT/code.apparmor $pkgdir/
cp $ROOT/code.desktop $pkgdir/

exit 0
