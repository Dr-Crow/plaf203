#!/bin/sh

restart_app()
{
    killall ak_tuya_ipc

    ret=`cat /tmp/wpa_conf |grep $UO_WIFI_SSID`
    if [ "$ret" != "" ];then
        killall tutk_product_test
    fi
}

while true
do
    sleep 5
    let cnt+=1
    reg=`i2c_read_id -f -y 0 w2@0x30 0x39 0x11 r1`
    if [ "$reg" \> "0x15" ];then
        echo "read 0x3911 error for sc223a" > /mnt/config/sc223a_error
        restart_app
        sleep 10
    fi

    if [ $cnt -gt 60 ];then
        exit 0
    fi
done

