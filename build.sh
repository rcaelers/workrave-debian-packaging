#!/bin/sh -x

BUILD=/home/robc/src/workrave-build
mkdir -p "$BUILD"

SOURCE="$1"
VERSION=`echo $SOURCE | sed -e 's/.*-\(.*\).tar.gz/\1/'`

echo "Preparing build environment"

rm -rf "$BUILD/workrave-$VERSION" || exit 1
tar xzfC "$SOURCE" "$BUILD" || exit 1
cp "$SOURCE" "$BUILD/workrave_$VERSION.orig.tar.gz" || exit 1
cp -r ./debian "$BUILD/workrave-$VERSION/debian" || exit 1

(   rm -rf "$BUILD/local" > /dev/null 2>&1 ;
    mkdir -p "$BUILD/local" && 
    ln "$SOURCE" "$BUILD/local/workrave_$VERSION.orig.tar.gz" && 
    cp -a "$BUILD/workrave-$VERSION" "$BUILD/local" && 
    cd "$BUILD/local/workrave-$VERSION" &&
    series=`lsb_release -c | cut -f2` &&
    if [ -d debian/${series} ]; then
	mv -f debian/${series}/* debian
	rmdir debian/${series}
    fi
    sudo ARCH=amd64 pdebuild --debbuildopts "-j12 -sa"
    ) > local.log 2>&1

