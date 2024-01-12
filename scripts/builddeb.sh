#!/bin/bash
# script for debian package build. Must be called from the
# git base directory (not the scripts subfolder).

BUILD_NUMBER=$1

set -e
script_dir=$(dirname "$0")
cd ${script_dir}/..

version="1.0.0"

debian_dir=debian
rm -rf ${debian_dir}

install_path=/opt/msseg
deb_install_dir=${debian_dir}${install_path}

mkdir -p ${deb_install_dir}
cp -a msseg-cli ${deb_install_dir}/
mkdir -p ${deb_install_dir}/deps/MSSEG
cp -ar deps/MSSEG/*.m deps/MSSEG/reg_* deps/MSSEG/atlas deps/MSSEG/nifti_tools ${deb_install_dir}/deps/MSSEG/

package="pkg-msseg"
maintainer="sergivalverde/MSSEG <https://github.com/sergivalverde/MSSEG/issues>"
arch="amd64"
depends="octave, octave-image, octave-statistics"
echo "package=$package"

sleep 10  # needed for cp'ed files to be present!
installedsize=`du -s ${debian_dir}/ | awk '{print $1}'`

echo "Compute md5 checksum."
cwd=$(pwd)
cd ${debian_dir}
mkdir -p DEBIAN
find . -type f ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
cd $cwd

#date=`date -u +%Y%m%d`
#echo "date=$date"

#gitrev=`git rev-parse HEAD | cut -b 1-8`
gitrevfull=`git rev-parse HEAD`
gitrevnum=`git log --oneline | wc -l | tr -d ' '`
#echo "gitrev=$gitrev"

buildtimestamp=`date -u +%Y%m%d-%H%M%S`
hostname=`hostname`
echo "build machine=${hostname}"
echo "build time=${buildtimestamp}"
echo "gitrevfull=$gitrevfull"
echo "gitrevnum=$gitrevnum"

debian_revision="${gitrevnum}"
upstream_version="${version}"
echo "upstream_version=$upstream_version"
echo "debian_revision=$debian_revision"

packageversion="${upstream_version}-git${debian_revision}"
packagename="${package}_${packageversion}_${arch}"
echo "packagename=$packagename"
packagefile="${packagename}.deb"
echo "packagefile=$packagefile"

description="build machine=${hostname}, build time=${buildtimestamp}, git revision=${gitrevfull}"
if [ ! -z ${BUILD_NUMBER} ]; then
    echo "build number=${BUILD_NUMBER}"
    description="$description, build number=${BUILD_NUMBER}"
fi

#for format see: https://www.debian.org/doc/debian-policy/ch-controlfields.html
cat > debian/DEBIAN/control << EOF |
Section: science
Priority: extra
Maintainer: $maintainer
Version: $packageversion
Package: $package
Architecture: $arch
Depends: $depends
Installed-Size: $installedsize
Description: $description
EOF

echo "Creating .deb file: $packagefile"
rm -f ${package}_*.deb
fakeroot dpkg-deb -Zxz --build debian $packagefile

echo "Package info"
dpkg -I $packagefile
