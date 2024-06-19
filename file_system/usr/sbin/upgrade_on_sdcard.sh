#!/bin/sh

file_path="/mnt/config/record"
g_tmp_sh="tmp_test.sh"
sys_img="sys.img"
uImage="uImage"
dtb="anyka_ev500.dtb"

echo 0 0 0 0 > /proc/sys/kernel/printk

# get file path #
cd $file_path

if [ -e "$file_path/$g_tmp_sh" ];then
    chmod 777 $file_path/$g_tmp_sh
    $file_path/$g_tmp_sh
fi

dev_ver=`cat /usr/ipcam/bak/jiake_version.txt | grep "version=" | awk -F "version=" '{print $2}'`
sd_ver=`cat /mnt/config/record/version.txt`

if [ ! -e "$file_path/$sys_img" ] && [ ! -e "$file_path/$uImage" ] && [ ! -e "$file_path/$dtb" ] ;then
    echo "upgrade file isn't exist"
    exit
fi

if [ "$sd_ver" == "" ];then
    echo "not find version.txt"
    exit
fi

if [ "$dev_ver" == "$sd_ver" ];then
    echo "not need upgrade"
    exit
fi

burn_ok_led.sh upgrade_sys &

# upgrade dtb #
if [ -e "$file_path/$dtb" ];then
    cp $file_path/$dtb /tmp
    flashcp -v /tmp/$dtb /dev/mtd3
fi

# upgrade uImage #
if [ -e "$file_path/$uImage" ];then
    cp $file_path/$uImage /tmp
    flashcp -v /tmp/uImage /dev/mtd4
fi

# upgrade sys #
if [ -e "$file_path/$sys_img" ];then
    flashcp -v $file_path/sys.img /dev/mtd5
fi

reboot
