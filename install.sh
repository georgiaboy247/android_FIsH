#!/bin/bash
#####################################################################################################
#
# This is Android FIsH: [F]luffy [I]ncredible [s]teadfasterX [H]ijack
#
# Copyright (C) 2017 steadfasterX <steadfastX@boun.cr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
######################################################################################################

echo "***************************************************************"
echo "** FIsH: [F]luffy [I]ncredible [s]teadfasterX [H]ijack       **"
echo "**                                                           **"
echo "**                        brought to u by: steadfasterX ;)   **"
echo "**                                                           **"
echo "** ... and MANY thx for your ideas and work @Aaahh !         **"
echo "***************************************************************"

# the required android version -> have to match the fish you package 
# (e.g. TWRP have to be compatible with that version)
# This version here means the STOCK ROM version you expect for this package!
REQBUILD="5.1"

# minimal required SuperSU version. TRUST me u will encounter problems with >2.79!
# well 2.67 should work but i will not tell anyone ;) (totally untested)
MINSU="279"

# The full URL to the busybox version compatible to your device:
BUSYBOXURI="https://busybox.net/downloads/binaries/1.26.2-defconfig-multiarch/busybox-armv6l"

# precheck min requirement adb:
adb version
[ $? -ne 0 ]&& echo "ADB is not installed?! Use FWUL (https://tinyurl.com/FWULatXDA) you FOOL! :)" && exit

F_ERR(){
    ERR=${1/*=/}
    [ -z "$ERR" ]&& echo "ERROR IN ERROR HANDLING! $1 was cut down to: $ERR" && exit

    if [ "$ERR" -ne 0 ];then
        echo "--> ERROR!! ABORTED WITH ERROR $ERR! Check the above output!"
        exit 3
    else
        echo "-> command ended successfully ($1)"
    fi
}

# we do not want to distribute busybox to avoid licensing issues so u need to download it:
echo -e "\n############# Checking for busybox"
[ ! -f fishing/busybox ] && echo "...downloading busybox" && wget "$BUSYBOXURI" -O fishing/busybox && chmod 755 fishing/busybox
[ ! -f fishing/busybox ] && echo "ERROR: MISSING BUSYBOX! Download it manually and place it in the directory: ./fishing/ and name it <busybox>" && exit 3

#echo "############# waiting for a connected adb device"
#adb wait-for-device
echo "############# checking Android version"
AVER=$(adb shell getprop ro.build.version.release| tr -d '\r')
if [ "$AVER" != "$REQBUILD" ];then
    echo "ERROR! You have Android $AVER running but $REQBUILD is required. FIsH will not be able to boot! ABORTED."
    exit 3
else
    echo "-> Matching required Android version: $REQBUILD"
fi

echo "############# checking SuperSU version"
SUVER=$(adb shell su -v|cut -d ":" -f1 |tr -d '.'| tr -d '\r')
if [ "$SUVER" -ge "$MINSU" ];then
    echo "-> Matching required SuperSU version: $SUVER"
else
    echo "ERROR! You have SuperSU $SUVER running but $MINSU is required. FIsH will not be able to boot! ABORTED."
    echo "Update to at least v${MINSU} with e.g. FlashFire or similar."
    exit 3
fi

echo "############# temporary disable SELinux"
RET=$(adb shell 'su -c setenforce 0; echo err=$?' | grep err=|tr -d '\r')
F_ERR $RET
SEL="$(adb shell getenforce|tr -d '\r')"
echo "SELinux mode: $SEL"
[ "$SEL" != "Permissive" ]&& echo 'ABORTED!!! YOU CAN NOT GET PERMISSIVE SELINUX MODE!' && exit
echo "############# cleaning"
RET=$(adb shell 'su -c rm -Rf /data/local/tmpfish/; echo err=$?' | grep err= |tr -d '\r')
F_ERR $RET
echo "############# creating temporary directory"
RET=$(adb shell 'su -c mkdir /data/local/tmpfish; echo err=$?' | grep err=|tr -d '\r')
F_ERR $RET
RET=$(adb shell 'su -c chmod 777 /data/local/tmpfish; echo err=$?' | grep err=|tr -d '\r')
F_ERR $RET
echo "############# pushing files"
for fishes in $(find fishing/ -type f );do adb push $fishes /data/local/tmpfish/;done
RET=$(adb shell 'su -c chmod 755 /data/local/tmpfish/gofishing.sh; echo err=$?' | grep err=|tr -d '\r')
F_ERR $RET
echo "############# remount /system"
RET=$(adb shell "su -c 'mount -oremount,rw /system; echo err=$?'" | grep err=|tr -d '\r') # bullshit.. mount do not return a valid errorcode!
#F_ERR $RET
echo "############# injecting the FIsH"
RET=$(adb shell 'su -c /data/local/tmpfish/gofishing.sh; echo err=$?' | grep err=|tr -d '\r')
F_ERR $RET
echo "############# remount /system RO again"
RET=$(adb shell 'su -c mount -oremount,ro /system; echo err=$?' | grep err=|tr -d '\r') # bullshit.. mount do not return a valid errorcode!
#F_ERR $RET
echo "ALL DONE! Reboot and enjoy the FIsH."
echo
echo -e "Get support on IRC:\n"
echo -e "\tInstall HexChat (https://hexchat.github.io) -> channel #Carbon-user on freenode"
echo -e "\tor"
echo -e "\tOpen: http://webchat.freenode.net/?channels=Carbon-user"
echo 
echo
