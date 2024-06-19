#!/bin/sh

source echo_type.sh

mkdir -p $G_WIFI_MOD_INFO_PATH

id_8188="0bda:f179"
id_atbm="007a:8888"
id_6x5x="8065:6000"
txt_file=$G_WIFI_MOD_INFO_PATH/usb_info.txt
g_lsusb_cnt=0

while true
do
    if [ $g_lsusb_cnt -ge 80 ];then
        JKsh_echo_err "lsusb timeout"
        g_lsusb_cnt=0
        break
    fi

    lsusb | grep "Device 002"
    if [ $? -eq 0 ];then
        JKsh_echo_info "wifi bus ok"
        break
    fi
    sleep 0.1
    let g_lsusb_cnt++
done

lsusb > $txt_file
if [ `grep -c "$id_8188" $txt_file` -ne '0' ];then
    JKsh_echo_info "wifi is 8188"
    touch $G_WIFI_MOD_INFO_PATH/wifi_8188
elif [ `grep -c "$id_atbm" $txt_file` -ne '0' ];then
    JKsh_echo_info "wifi is atbm"
    touch $G_WIFI_MOD_INFO_PATH/wifi_atbm
    mkdir /tmp/bin
    ln -s /usr/sbin/hostapd_nl82011 /tmp/bin/hostapd
elif [ `grep -c "$id_6x5x" $txt_file` -ne '0' ];then
    JKsh_echo_info "wifi is 6x5x"
    touch $G_WIFI_MOD_INFO_PATH/wifi_6x5x
else
    JKsh_echo_warn "no check wifi module"
fi
