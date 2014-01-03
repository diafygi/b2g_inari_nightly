#!/bin/bash

#sync the repo
cd "${HOME}/B2G" && git pull
cd "${HOME}/B2G" && ./repo sync -d

#download the ZTE released update file with binary blobs
if [ ! -d "${HOME}/B2G/backup-inari" ]
then
    wget "http://download.ztedevices.com/UpLoadFiles/product/643/3601/soft/2013121011161582.zip" -O "/tmp/update.zip"
    unzip "/tmp/update.zip" -d "/tmp/update"
    unzip "/tmp/update/US_DEV_FFOS_V1.0.0B02_USER_SD.zip" -d "${HOME}/B2G/backup-inari"
    rm "/tmp/update.zip"
    rm -r "/tmp/update"
fi

#loop through the desired nightly build branches
b2gversions=( "master" "v1.2" "v1.3" )
for v in "${b2gversions[@]}"
do
    #config the build
    cd ~/B2G && yes "b2g\ndev-b2g@lists.mozilla.org" | BRANCH="${v}" ./config.sh inari

    #build using gcc 4.6
    export CC=gcc-4.6
    export CXX=g++-4.6
    cd ~/B2G && ./build.sh

    #move the build to a temp folder
    CMM=$(cd ~/B2G/ && git log --pretty=format:"%h" | head -1)
    MDY=$(date +"%Y-%m-%d")
    BLD=$(echo "b2g_inari_${v}_${MDY}_${CMM}")
    mkdir -p "${HOME}/${BLD}/out/target/product/inari/"
    cp ~/B2G/flash.sh "${HOME}/${BLD}/"
    cp ~/B2G/load-config.sh "${HOME}/${BLD}/"
    cp ~/B2G/.config "${HOME}/${BLD}/"
    cp ~/B2G/out/target/product/inari/userdata.img "${HOME}/${BLD}/out/target/product/inari/"
    cp ~/B2G/out/target/product/inari/system.img "${HOME}/${BLD}/out/target/product/inari/"

    #copy needed boot.img to build (http://sl.edujose.org/2013/10/adapted-boot-image-for-use-with-b2g.html)
    cp ~/b2g_inari_nightly/boot_adapted_for_zte_open_commercial_editions.img "${HOME}/${BLD}/out/target/product/inari/boot.img"

    #create new build files and remove old builds (>2 weeks old)
    cd "${HOME}" && tar -zcvf "${HOME}/builds/${BLD}.tar.gz" "${BLD}"
    rm -r "${HOME}/${BLD}"
    md5sum "${HOME}/builds/${BLD}.tar.gz" | awk '{ print $1 }' > "${HOME}/builds/${BLD}.md5"
    cp "${HOME}/builds/${BLD}.tar.gz" "${HOME}/builds/b2g_inari_${v}_latest.tar.gz"
    cp "${HOME}/builds/${BLD}.md5" "${HOME}/builds/b2g_inari_${v}_latest.md5"
    find "${HOME}/builds/" -mtime +14 | xargs rm
done
