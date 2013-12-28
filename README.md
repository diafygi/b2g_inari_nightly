#Nightly Firefox OS builds for the ZTE Open (inari)

This is the code I'm using to build nightly versions of Firefox OS (Boot-2-Gecko, or b2g for short). I am building on a VPS with 3GB of RAM and Debian 7. I based these steps off of the official Firefox OS Build instructions: https://developer.mozilla.org/en-US/Firefox_OS/Building_and_installing_Firefox_OS

The `build_branches.sh` and `README.md` is released under the GPLv2. The other files (`boot_adapted_for_zte_open_commercial_editions.img` and `backup-inari.zip`) are released under their owner's respective licenses.

##Download Nightly Builds

You can find the output nightly builds of this script here:

https://daylightpirates.org/b2g_inari_nightly_builds/

##Disclaimer

I offer NO guarantee and NO warranty for these builds. They are purely experimental and NOT official builds. If you brick your phone, it's your own damn fault. I have only tried several of these on the ZTE Open US version, so flashing them to the UK or other country versions may not work as well (I'm open to forks making UK-friendly builds). Also, flashing them to non-inari (ZTE Open's code name) devices will probably brick your phone (so don't do it).

##Steps to flash one of these builds to your ZTE Open (US version)

1. Make sure your ZTE Open has [fastboot enabled](https://developer.mozilla.org/en-US/Firefox_OS/Developer_phone_guide/ZTE_OPEN#Revision_02). If you don't have fastboot enabled (or don't know if you do), follow my instructions [here](https://bugzilla.mozilla.org/show_bug.cgi?id=928659#c2).

2. Install [adb and fastboot](https://developer.mozilla.org/en-US/Firefox_OS/Firefox_OS_build_prerequisites#Install_adb).

3. Enable [remote debugging](https://developer.mozilla.org/en-US/Firefox_OS/Firefox_OS_build_prerequisites#Enable_remote_debugging) on the device.

4. Configure [udev rules](https://developer.mozilla.org/en-US/Firefox_OS/Firefox_OS_build_prerequisites#For_Linux.3A_configure_the_udev_rule_for_your_phone) for your device (Linux only, I had to have two lines, one for adb, one for fastboot).

    ```
    SUBSYSTEM=="usb", ATTR{idVendor}=="19d2", MODE="0666", GROUP="plugdev" # ZTE Open
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev" # Google device
    ```

5. Plug in your phone and make sure it is recognized on adb.

    ```
    adb devices
    ```

6. Download one of the latest builds from https://daylightpirates.org/b2g_inari_nightly_builds/ (the three nightly build versions are master, v1.2, and v1.3).

7. Extract all the files to a b2g_inari directory.

    ```
    tar -zxvf b2g_inari_<version>_<date>_<commit>.tar.gz
    ```

8. Run the flash script in the extracted directory.

    ```
    ./flash.sh
    ```

##Steps to setup your own nightly builder

1. Install the prerequisites.

    ```
    sudo dpkg --add-architecture i386
    sudo apt-get install autoconf2.13 bison bzip2 ccache curl flex gawk gcc g++ g++-multilib gcc-4.6 g++-4.6 g++-4.6-multilib cpp g++-4.7 gcc-4.7 gcc-multilib g++-4.7-multilib git lib32ncurses5-dev lib32z1-dev zlib1g:amd64 zlib1g-dev:amd64 zlib1g:i386 zlib1g-dev:i386 libgl1-mesa-dev libx11-dev make zip cmake libxml2-utils openjdk-7-jre openjdk-7-jdk libdbus-glib-1-2 libxt-dev patch
    ```

2. Clone the night builder files from github.

    ```
    git clone https://github.com/diafygi/b2g_inari_nightly.git ~/b2g_inari_nightly
    ```

3. Clone the b2g repo from github.

    ```
    git clone git://github.com/mozilla-b2g/B2G.git ~/B2G
    ```

4. Unzip the backup (needed for drivers) int the B2G folder.

    ```
    unzip ~/b2g_inari_nightly/backup-inari.zip -d ~/B2G
    ```

5. Create the builds folder.

    ```
    mkdir ~/builds
    ```

6. Create an entry in your cron (example below runs every morning at 1:00 a.m. local time).

    ```
    0 1 * * * ~/b2g_inari_nightly/build_branches.sh &> /tmp/buildlog.log
    ```

7. Add a location to your web server to serve the files (I used nginx).

    ```
    location /b2g_inari_nightly_builds {
        alias /path/to/builds/;
        autoindex on;
    }
    ```

##Manually building

If you ever want to run the build script manually.

1. Follow steps 1-5 of the above "Steps to setup your own nightly builder".

2. Manually run the "build_branches.sh" script (I'd recommend running it in a screen (since it will take a while).

    ```
    screen -S b2g
    ~/b2g_inari_nightly/build_branches.sh
    <ctrl>+a d (detaches the screen)
    screen -r b2g (attaches the screen so you can check on the status)
    ```

##Support

I am subscribed to the dev-b2g mailing list, so you can post questions about installing the builds there:

https://lists.mozilla.org/listinfo/dev-b2g

If there are bugs with the builds after you install them, please submit bug reports to the main mozilla bug tracker, and please include the branch (master, v1.2, v1.3) and commit hash (from the filename):

https://bugzilla.mozilla.org/


