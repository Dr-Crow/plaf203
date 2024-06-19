#!/bin/sh

source link_led_ctrl.sh
source echo_type.sh

wifi_dev="wlan0"
g_led_state_flag="/mnt/config/dp_file_flag/on_light_led_file"
g_low_battery_flag="/tmp/low_battery"
g_motor_bad_flag="/tmp/motor_abnormal"
g_close_led_flag="/tmp/mcu_open_warning_led"
g_fast_blink_flag="/tmp/led_fast_blink"
g_flag_mqtt_offline="/tmp/mqtt_offline"
#network count
net_num=0
g_rm_ko_num=0
max_connect_cnt=20

JKsh_led_fast_blink()
{
    while true
    do
        if [ -e $g_low_battery_flag ];then
            return
        fi

        if [ -e $g_fast_blink_flag ];then
            JKsh_led_ctrl 0
            sleep 0.25
            JKsh_led_ctrl 1
            sleep 0.25
        else
            sleep 0.1
        fi
    done
}

JKsh_link_led_status()
{
    if [ -e $g_close_led_flag ] || [ -e $g_motor_bad_flag ];then
        JKsh_led_ctrl 0
    else
        if [ -e $g_led_state_flag ];then
            JKsh_led_ctrl 1
        else
            JKsh_led_ctrl 0
        fi
    fi
}

JKsh_led_fast_blink &

while true 
do
    if [ ! -e $g_flag_mqtt_offline ];then
        JKsh_echo_info "Network normal !!!"
        net_num=0
        if [ -e $g_fast_blink_flag ];then
            rm $g_fast_blink_flag
        fi
        JKsh_link_led_status
        sleep 60
        continue
    else
        let net_num=net_num+1
    fi

    if [ $net_num -ge $max_connect_cnt ];then
        JKsh_echo_warn "Reconnect to the network !!!"
        net_num=0
        killall -9 wpa_supplicant
        killall -9 udhcpc
        if [ $g_rm_ko_num -ge 80 ];then
            JKsh_echo_warn "----------rm wifi ko----------"
            g_rm_ko_num=0
            rmmod $G_WIFI_MODULE ak_hcd usbcore
            insmod /lib/modules/usbcore.ko
            insmod /lib/modules/ak_hcd.ko
            insmod /lib/modules/$G_WIFI_MODULE.ko stacfgpath=/etc/ssv6x5x-wifi.cfg
            sleep 3
        fi
        ifconfig $wifi_dev up
        wpa_supplicant -B -i$wifi_dev -c/tmp/wpa_conf
        udhcpc -i$wifi_dev -b -x hostname:$PRODUCT_MODE
        if [ ! -e $g_fast_blink_flag ];then
            touch $g_fast_blink_flag
        fi
        let g_rm_ko_num++
    fi

    sleep 1
done

