#!/bin/sh

wifi_dev="wlan0"
burn_uuid_flag=0
burn_uuid_cnt=0

NOW_UUID=$(cat /mnt/config/tuya_config.txt | grep "UUID" | awk -F "UUID=" '{print $2}')
if [ "$NOW_UUID" = "01234567890123456789" ];then
    echo "UUID is NULL now !!"
else
    echo "UUID is exit now !!"
    touch /tmp/burn_uuid_ok
fi

if [ ! -e /tmp/burn_uuid_ok ] ; then
    test_ssid="ty_burn_uuid"
    burn_uuid_flag=1
else
    if [ ! -e "/mnt/config/burn_uuid_ok" ];then
        test_ssid="ty_burn_uuid"
        burn_uuid_flag=1
    else
        test_ssid=$UO_WIFI_SSID
    fi
fi
test_pwd="12345678"
rtw_conf=/tmp/wpa_conf

while true
do
    #wait for driver ready.
    ret=`ifconfig | grep $wifi_dev`
    if [ "$ret" = "" ];then
        ifconfig $wifi_dev up
        sleep 2
        continue
    fi

    #check and connect to the special ssid.
    ret=`iwlist $wifi_dev scan |grep $test_ssid`
    if [ "$ret" != "" ];then
        ssid=`echo ${ret#*\"}`
        ssid=`echo ${ssid%%\"*}`
    fi

    if [ "$ssid" = "$test_ssid" ];then
        WPAstr="ctrl_interface=/var/run/wpa_supplicant\nap_scan=1\nnetwork={\n\tssid=\"$test_ssid\"\n\tscan_ssid=1\n\tpsk=\"$test_pwd\"\n}\n";
        echo -e $WPAstr > $rtw_conf
        echo "find test_ssid: $test_ssid"
        while true
        do
            ip_addr=$(ifconfig wlan0|grep "inet addr:"|awk -F "inet addr:" '{print $2}'|awk -F ' ' '{print $1}')
            if [ ! -z "$ip_addr" ] && [ "$ip_addr" != "192.168.0.1" ];then
                echo "IP Address is "$ip_addr
                if [ $burn_uuid_flag -eq 1 ];then
                    http_download_tutk_test.sh burn_uuid
                else
                    http_download_tutk_test.sh hardware_test
                    tutk_test_daemon.sh &
                fi
                return 0
            else
                echo "ip_addr is NULL , start udhcpc !!"
                killall -9 wpa_supplicant
                killall -9 udhcpc

                wpa_supplicant -B -iwlan0 -c /tmp/wpa_conf
                udhcpc -i wlan0 -b -x hostname:$PRODUCT_MODE
            fi
        done
    fi

    if [ $burn_uuid_flag -eq 1 ];then
        if [ $burn_uuid_cnt -eq 3 ];then
            echo "don't scan product test ssid"
            return 1
        fi
        let burn_uuid_cnt++
    else
        echo "don't scan product test ssid"
        return 1
    fi
done
