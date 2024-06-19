#!/bin/sh

wifi_dev="wlan0"
file_path="/tmp"
sys_img="sys.img"
sys_md5="sys_md5.txt"
uImage="uImage"
uImage_md5="uImage_md5.txt"
dtb="anyka_ev500.dtb"
dtb_md5="dtb_md5.txt"
http_ip_and_port="http://192.168.7.11:8088"
http_server_addr="$http_ip_and_port/V330/$PRODUCT_MODE"

ver_str=`cat /mnt/config/jiake_version.txt | grep "version=" | awk -F "version=" '{print $2}'`
ver_len=${#ver_str}
product_type_len=$(($ver_len-3))
ver_num_len=$(($ver_len-2))
ver_num=${ver_str:$ver_num_len}
product_type=${ver_str:0:$product_type_len}
upgrade_wifi_name="upgrade_"$product_type

while true
do
    # wait for driver ready. #
    ret=`ifconfig | grep $wifi_dev`
    if [ "$ret" = ""  ];then
        ifconfig $wifi_dev up
    else
        break
    fi
    sleep 0.3
done

# check and connect to the special ssid. #
ret=`iwlist $wifi_dev scan | grep $upgrade_wifi_name`
if [ "$ret" != ""  ];then
    upgrade_ssid=`echo ${ret#*\"}`
    upgrade_ssid=`echo ${upgrade_ssid%%\"*}`
else
    echo "no scan upgrade wifi ssid"
    exit
fi

wifi_ver_num=`echo $upgrade_ssid | awk -F $upgrade_wifi_name"." '{print $2}'`
# compare firmware version #
if [ "$wifi_ver_num" -eq "$ver_num" ];then
    echo "no need to upgrade firmware version"
    exit
fi

wpa_passphrase "$upgrade_ssid" 12345678 > /tmp/wpa_conf

# execute led ctrl shell #
http_upgrade_led_ctrl.sh &

# connect to WiFi network #
wpa_supplicant -B -i$wifi_dev -c /tmp/wpa_conf
udhcpc -i$wifi_dev -b -x hostname:$PRODUCT_MODE

while true
do
    ip_addr=$(ifconfig wlan0|grep "inet addr:"|awk -F "inet addr:" '{print $2}'|awk -F ' ' '{print $1}')
    if [ ! -z "$ip_addr" ];then
        echo "IP Address is "$ip_addr
        break
    else
        echo "ip_addr is NULL , start udhcpc !!"
        killall -9 wpa_supplicant
        killall -9 udhcpc

        wpa_supplicant -B -i$wifi_dev -c /tmp/wpa_conf
        udhcpc -i$wifi_dev -b -x hostname:$PRODUCT_MODE
        continue
    fi
    sleep 0.1
done

touch $file_path/connect_wifi_success

# get file path #
cd $file_path

# download system #
wget -t 3 -T 30 -P $file_path $http_server_addr/$sys_img
if [ $? = 0 ];then
    echo "wget sys ok"
    wget -t 3 -T 30 -P $file_path $http_server_addr/$sys_md5
else
    echo "wget sys failed"
fi

# download uImage #
wget -t 3 -T 30 -P $file_path $http_server_addr/$uImage
if [ $? = 0 ];then
    echo "wget uImage ok"
    wget -t 3 -T 30 -P $file_path $http_server_addr/$uImage_md5
else
    echo "wget uImage failed"
fi

# download dtb #
wget -t 3 -T 30 -P $file_path $http_server_addr/$dtb
if [ $? = 0 ];then
    echo "wget dtb ok"
    wget -t 3 -T 30 -P $file_path $http_server_addr/$dtb_md5
else
    echo "wget dtb failed"
fi

# upgrade dtb #
if [ -e "$file_path/$dtb" ];then
    local_md5=`md5sum $file_path/$dtb | awk -F ' ' '{print $1}'`
    get_md5=`cat $file_path/$dtb_md5`
    if [ "$local_md5" = "$get_md5" ];then
        echo "upgrade dtb now"
        flashcp -v $file_path/$dtb /dev/mtd3
        echo "upgrade dtb success"
    else
        echo "dtb md5 is error"
    fi
fi

# upgrade uImage #
if [ -e "$file_path/$uImage" ];then
    local_md5=`md5sum $file_path/$uImage | awk -F ' ' '{print $1}'`
    get_md5=`cat $file_path/$uImage_md5`
    if [ "$local_md5" = "$get_md5" ];then
        echo "upgrade uImage now"
        flashcp -v /tmp/uImage /dev/mtd4
        echo "upgrade uImage success"
    else
        echo "uImage md5 is error"
    fi
fi

# upgrade sys #
if [ -e "$file_path/$sys_img" ];then
    local_md5=`md5sum $file_path/$sys_img | awk -F ' ' '{print $1}'`
    get_md5=`cat $file_path/$sys_md5`
    if [ "$local_md5" = "$get_md5" ];then
        echo "upgrade sys now"
        flashcp -v /tmp/sys.img /dev/mtd5
        touch "$file_path/upgrade_ok"
        echo "upgrade sys success"
    else
        echo "sys md5 is error"
        touch "$file_path/upgrade_failed"
    fi
fi

if [ ! -e "$file_path/$sys_img" ] && [ ! -e "$file_path/$uImage" ];then
    echo "upgrade file isn't exist"
    touch "$file_path/upgrade_failed"
fi

# download upgrade_test.sh #
rm /tmp/upgrade_test.sh
wget -t 3 -T 30 -P $file_path $http_server_addr/upgrade_test.sh
if [ $? = 0  ];then
    echo "wget upgrade_test.sh ok"
    chmod 777 /tmp/upgrade_test.sh
    /tmp/upgrade_test.sh &
else
    echo "wget upgrade_test.sh failed"
fi

# device waiting for reboot #
while true
do
    sleep 3
done
