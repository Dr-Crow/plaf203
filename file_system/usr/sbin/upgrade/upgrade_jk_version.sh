#!/bin/sh

# killall proces #
free_memory.sh

upgrade_dtb()
{
    if [ -e "/tmp/anyka_ev500.dtb" ];then
        echo "wait,upgrade anyka_ev500.dtb now !!"
        flashcp -v /tmp/anyka_ev500.dtb /dev/mtd3
    else
        echo "/tmp/anyka_ev500.dtb is not exist !!"
    fi
    sleep 0.5
}

upgrade_uImage()
{
    if [ -e "/tmp/uImage" ];then
        echo "wait,upgrade uImage now !!"
        flashcp -v /tmp/uImage /dev/mtd4
    else
        echo "/tmp/uImage is not exist !!"
    fi
    sleep 0.5
}

upgrade_filesystem()
{
    if [ -e "/tmp/sys.img" ];then
        echo "wait,upgrade now !!"
        upgrade_dtb
        upgrade_uImage
        flashcp -v /tmp/sys.img /dev/mtd5
        echo "upgrade success,reboot now !!"
        sleep 1
        reboot
    else
        echo "/tmp/sys.img is not exist !!"
    fi
}

upgrade_filesystem
