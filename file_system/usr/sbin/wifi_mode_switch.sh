#!/bin/sh

wifi_dev=$2
#ap channel
max_chn=1
wifi_module="rtl8188fu"

#killall AP mode tool
killall -9 hostapd
killall -9 udhcpd
killall -9 wpa_passphrase
killall -9 wpa_supplicant
killall -9 udhcpc

get_ap_best_chn()
{
    iwlist $wifi_dev scan

    wifi_loading_file="/tmp/wifi_chn_loading"
    cat /proc/net/$wifi_module/wlan0/best_channel | grep "The rx cnt of channel" | awk -F "= " '{print $2}' > $wifi_loading_file
    cur_cnt=0
    ret=`cat $wifi_loading_file |wc -l`
    if [ $ret -gt 0 ]; then
        while read line
        do
            let cur_cnt++
            # frist get loading #
            if [ $cur_cnt -eq 1 ];then
                max_loading=$line
                max_chn=$cur_cnt
                continue
            fi

            if [ $line -ge $max_loading ];then
                max_loading=$line
                max_chn=$cur_cnt
            fi
        done < $wifi_loading_file
    fi
}

get_ap_random_chn()
{
    rand_chn=$((RANDOM%13+1))
    #echo $rand_chn
    if [ $rand_chn -le 4 ];then
        max_chn=1
    elif [ $rand_chn -le 8 ];then
        max_chn=6
    elif [ $rand_chn -le 12 ];then
        max_chn=11
    elif [ $rand_chn -eq 13 ];then
        max_chn=13
    fi
}

if [ "$1" = "AP" ];then
    host_conf=/etc/init.d/hostapd.conf
    atbm_host_conf=/etc/init.d/atbm_hostapd.conf
    udhcpd_conf=/etc/udhcpd.conf
    cp_host_conf=/tmp/hostapd.conf

    if [ $G_WIFI_MODULE = "atbm_wifi" ];then
        cp $atbm_host_conf $cp_host_conf
    else
        cp $host_conf $cp_host_conf
    fi

    if [ $G_WIFI_MODULE = "8188fu" ];then
        get_ap_best_chn
    else
        get_ap_random_chn
    fi

    ap_chn="s/channel=6/channel=$max_chn/g"
    sed -i $ap_chn $cp_host_conf
    ap_name="s/jiake_ap/$3/g"
    sed -i $ap_name $cp_host_conf
    hostapd -B $cp_host_conf
    ifconfig $wifi_dev 192.168.0.1
    udhcpd $udhcpd_conf

elif [ "$1" = "STA" ];then
    wpa_conf=/tmp/wpa_conf
    wep_conf=/tmp/wep_conf
    open_conf=/tmp/open_conf
    save_conf=/mnt/config/wpa_conf
    ssid_mode=$3
    wifi_encrypt_mode=1

    if [ $ssid_mode = "hide_ssid" ];then
        while true
        do
            killall -9 wpa_supplicant
            killall -9 udhcpc

            case $wifi_encrypt_mode in
                0)
                    wifi_encrypt_mode=1
                    wpa_supplicant -B -i$wifi_dev -c$open_conf
                    udhcpc -i$wifi_dev -b -x hostname:$PRODUCT_MODE

                    ip_addr=$(ifconfig wlan0|grep "inet addr:"|awk -F "inet addr:" '{print $2}'|awk -F ' ' '{print $1}')
                    if [ ! -z "$ip_addr" ];then
                        echo "OPEN_MODE IP Address is "$ip_addr
                        cp $open_conf $wpa_conf
                        cp $open_conf $save_conf
                        exit 0;
                    else
                        echo "OPEN_MODE ip_addr is NULL !!"
                        continue
                    fi
                    ;;
                1)
                    wifi_encrypt_mode=2
                    wpa_supplicant -B -i$wifi_dev -c$wpa_conf
                    udhcpc -i$wifi_dev -b -T 10 -x hostname:$PRODUCT_MODE

                    ip_addr=$(ifconfig wlan0|grep "inet addr:"|awk -F "inet addr:" '{print $2}'|awk -F ' ' '{print $1}')
                    if [ ! -z "$ip_addr" ];then
                        echo "WPA_MODE IP Address is "$ip_addr
                        cp $wpa_conf $save_conf
                        exit 0;
                    else
                        echo "WPA_MODE ip_addr is NULL !!"
                        continue
                    fi
                    ;;
                2)
                    wifi_encrypt_mode=0
                    wpa_supplicant -B -i$wifi_dev -c$wep_conf
                    udhcpc -i$wifi_dev -b -x hostname:$PRODUCT_MODE

                    ip_addr=$(ifconfig wlan0|grep "inet addr:"|awk -F "inet addr:" '{print $2}'|awk -F ' ' '{print $1}')
                    if [ ! -z "$ip_addr" ];then
                        echo "WEP_MODE IP Address is "$ip_addr
                        cp $wep_conf $wpa_conf
                        cp $wep_conf $save_conf
                        exit 0;
                    else
                        echo "WEP_MODE ip_addr is NULL !!"
                        continue
                    fi
                    ;;
            esac
            sleep 0.1
        done
    else
        cp $wpa_conf $save_conf
        wpa_supplicant -B -i$wifi_dev -c$wpa_conf
        udhcpc -i$wifi_dev -b -x hostname:$PRODUCT_MODE

        while true
        do
            ip_addr=$(ifconfig wlan0|grep "inet addr:"|awk -F "inet addr:" '{print $2}'|awk -F ' ' '{print $1}')
            if [ ! -z "$ip_addr" ];then
                echo "IP Address is "$ip_addr
                exit 0;
            else
                echo "ip_addr is NULL , start udhcpc !!"
                killall -9 wpa_supplicant
                killall -9 udhcpc

                wpa_supplicant -B -i$wifi_dev -c$wpa_conf
                udhcpc -i$wifi_dev -b -x hostname:$PRODUCT_MODE
                continue
            fi
            sleep 0.1
        done
    fi
fi

