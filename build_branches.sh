#!/bin/bash

#sync the repo
cd ~/B2G && git pull
~/B2G/repo sync -d

#loop through the desired nightly build branches
b2gversions=( "master" "v1.2" "v1.3" )
for v in "${b2gversions[@]}"
do
    #config the build
    yes "b2g\ndev-b2g@lists.mozilla.org" | BRANCH="${v}" ~/B2G/config.sh inari

    #build using gcc 4.6
    export CC=gcc-4.6
    export CXX=g++-4.6
    ~/B2G/build.sh

    #move the build to a temp folder
    CMM=$(git log --pretty=format:"%H" | head -1)
    MDY=$(date +"%Y-%m-%d")
    BLD=$(echo "b2g_inari_${v}_${MDY}_${CMM}")
    mkdir -p "~/${BLD}/out/target/product/inari/"
    cp ~/B2G/flash.sh "~/${BLD}/"
    cp ~/B2G/load-config.sh "~/${BLD}/"
    cp ~/B2G/.config "~/${BLD}/"
    cp ~/B2G/out/target/product/inari/userdata.img "~/${BLD}/out/target/product/inari/"
    cp ~/B2G/out/target/product/inari/system.img "~/${BLD}/out/target/product/inari/"

    #copy needed boot.img to build (http://sl.edujose.org/2013/10/adapted-boot-image-for-use-with-b2g.html)
    cp ~/b2g_inari_nightly/boot_adapted_for_zte_open_commercial_editions.img "~/${BLD}/out/target/product/inari/boot.img"

    #create new build files and remove old builds (>2 weeks old)

    tar -zcvf "~/builds/${BLD}.tar.gz" "~/${BLD}"
    rm -r "~/${BLD}"
    md5sum "~/builds/${BLD}.tar.gz" | awk '{ print $1 }' > "~/builds/${BLD}.md5"
    cp "~/builds/${BLD}.tar.gz" "~/builds/b2g_inari_${v}_latest.tar.gz"
    cp "~/builds/${BLD}.md5" "~/builds/b2g_inari_${v}_latest.md5"
    find "~/builds/*" -mtime +14 | xargs rm
done
