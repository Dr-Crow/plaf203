#!/bin/sh

source link_led_ctrl.sh

file_path="/mnt/config/record"
sys_img="sys.img"
uImage="uImage"
dtb="anyka_ev500.dtb"

echo 0 0 0 0 > /proc/sys/kernel/printk

# get file path #
cd $file_path

dev_ver=`cat /usr/ipcam/bak/jiake_version.txt | grep "version=" | awk -F "version=" '{print $2}'`
sd_ver=`cat /mnt/config/record/version.txt`
if [ ! -e "$file_path/$sys_img" ] && [ ! -e "$file_path/$uImage" ];then
    echo "upgrade file isn't exist"
    exit
fi

if [ -e "$file_path/mcu.bin" ];then
	burn_ok_led.sh upgrade_sys &
    cp $file_path/mcu.bin /tmp/
	cp $file_path/mcu_ver.txt /tmp/
	cp $file_path/jksdk_mcu_ota /tmp/
	chmod 777 /tmp/jksdk_mcu_ota
	/tmp/jksdk_mcu_ota
	killall burn_ok_led.sh 
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

killall burn_ok_led.sh

echo 15 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio15/direction

if [ ! -e "/mnt/config/plaf203_irled_new_hardware" ];then
	touch /mnt/config/plaf203_irled_new_hardware
else
	echo "plaf203_irled_new_hardware is exit"
fi

while true
do
	for i in 0 1
	do
		JKsh_led_ctrl 0
		sleep 0.25
		JKsh_led_ctrl 1
		sleep 0.25
	done
	sleep 1
done
