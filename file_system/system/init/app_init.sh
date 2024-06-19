#!/bin/sh

insmod /lib/modules/$G_SENSOR_NAME.ko
insmod /lib/modules/ak_gpio_keys.ko
insmod /lib/modules/$G_WIFI_MODULE.ko stacfgpath=/etc/ssv6x5x-wifi.cfg
insmod /lib/modules/ak_pwm_char.ko

if [ -d "/mnt/config/record" ];then
    echo "exist record folder"
else
    mkdir /mnt/config/record
fi

if [ -b "/dev/mmcblk0p1" ];then
    mount /dev/mmcblk0p1 /mnt/config/record/
elif [ -b "/dev/mmcblk0" ];then
    mount /dev/mmcblk0 /mnt/config/record/
else
    rm /mnt/config/record/* -rf
    echo "can't find sdcard"
fi

echo 0 0 0 0 > /proc/sys/kernel/printk

upgrade_on_sdcard.sh
start_tuya_ipc.sh &
