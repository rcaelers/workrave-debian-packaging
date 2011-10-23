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

for series in oneiric natty maverick
do
    echo Create $series source package
    (
	SERIES_VERSION=1
	
	if [ -d "$BUILD/$series/workrave-$VERSION" ]; then
	    OLD_VERSION=`dpkg-parsechangelog -l"$BUILD/$series/workrave-$VERSION/debian/changelog" | sed -n -e 's/^Version: \(.*\)/\1/p'`
	    OLD_PKG_VERSION=`echo $OLD_VERSION | sed -e 's/^\(.*ppa[0-9]\+\)~.*$/\1/'`
	    OLD_SERIES_VERSION=`echo $OLD_VERSION | sed -e "s/^.*~${series}\(.*\)$/\1/"`
	    echo O $OLD_VERSION
	    echo P $OLD_PKG_VERSION
	    echo S $OLD_SERIES_VERSION
	fi
	
	rm -rf "$BUILD/$series" > /dev/null 2>&1 ;
        mkdir -p "$BUILD/$series" && 
        ln "$SOURCE" "$BUILD/$series/workrave_$VERSION.orig.tar.gz" && 
        cp -a "$BUILD/workrave-$VERSION" "$BUILD/$series" && 
        cd "$BUILD/$series/workrave-$VERSION" &&

	NEW_VERSION=`dpkg-parsechangelog -l"$BUILD/$series/workrave-$VERSION/debian/changelog" | sed -n -e 's/^Version: \(.*\)/\1/p'`
	NEW_PKG_VERSION=`echo $NEW_VERSION | sed -e 's/^\(.*ppa[0-9]\+\)~.*$/\1/'`

	if [ "x$NEW_PKG_VERSION" = "x$OLD_PKG_VERSION" ]; then
	    SERIES_VERSION=`expr $OLD_SERIES_VERSION + 1`
	fi
	
	echo NO $NEW_VERSION
	echo NP $NEW_PKG_VERSION
	echo S $SERIES_VERSION
	
	if [ -d debian/${series} ]; then
	    mv -f debian/${series}/* debian
	    rmdir debian/${series}
	fi
	
	sed -i -e "1,1 s/^\(.*ppa[0-9]\+\)\(.*\)\().*\)$/\1~${series}${SERIES_VERSION}\3/" -e "1,1 s/^\(.*) \)\(.*\)\(;.*\)$/\1${series}\3/"  debian/changelog
        #debuild -S -sa -k3300F30F -j12
        )
    #> "$BUILD/${series}.log" 2>&1
done
