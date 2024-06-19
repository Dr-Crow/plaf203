#!/bin/sh

source echo_type.sh

mkdir -p $G_SENSOR_INFO_PATH

insmod /lib/modules/ak_rtc.ko
insmod /lib/modules/ak_i2c.ko
insmod /lib/modules/usbcore.ko
insmod /lib/modules/ak_hcd.ko
insmod /lib/modules/cfg80211.ko
insmod /lib/modules/mac80211.ko
insmod /lib/modules/ak_pcm.ko
insmod /lib/modules/ak_ion.ko
insmod /lib/modules/mmc_core.ko
insmod /lib/modules/mmc_block.ko
insmod /lib/modules/ak_mci.ko
insmod /lib/modules/ak_uio.ko
insmod /lib/modules/ak_isp.ko

echo 49 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio49/direction
echo 1 > /sys/class/gpio/gpio49/value

g_id_sc2336="0xcb 0x3a"
g_id_223a="0xcb 0x3e"
g_id_2232h="0xcb 0x07"
g_id_f37="0x0f 0x37"
g_id_mis2008="0x20 0x08"
g_id_gc2053="0x20 0x53"
g_id_h62="0xa0 0x62"
g_id_h63="0x0a 0x63"

read_1080p_sensor()
{
    str_1080p_id=`i2c_read_id -f -y 0 w2@0x30 0x31 0x07 r2`
    if [ "$str_1080p_id" = "$g_id_2232h" ];then
        JKsh_echo_info "sensor is 2232h"
        touch $G_SENSOR_INFO_PATH/sensor_2232h
        return 1
    elif [ "$str_1080p_id" = "$g_id_sc2336" ];then
        JKsh_echo_info "sensor is sc2336"
        touch $G_SENSOR_INFO_PATH/sensor_sc2336
        return 1
    elif [ "$str_1080p_id" = "$g_id_223a" ];then
        JKsh_echo_info "sensor is 223a"
        touch $G_SENSOR_INFO_PATH/sensor_223a
        sc223a_check.sh &
        return 1
    fi

    str_1080p_id=`i2c_read_id -f -y 0 w2@0x30 0x30 0x00 r2`
    if [ "$str_1080p_id" = "$g_id_mis2008" ];then
        JKsh_echo_info "sensor is mis2008"
        touch $G_SENSOR_INFO_PATH/sensor_mis2008
        return 1
    fi

    str_1080p_id=`i2c_read_id -f -y 0 w1@0x40 0xa r2`
    if [ "$str_1080p_id" = "$g_id_f37" ];then
        JKsh_echo_info "sensor is f37"
        touch $G_SENSOR_INFO_PATH/sensor_f37
        return 1
    fi

    str_1080p_id=`i2c_read_id -f -y 0 w1@0x37 0xf0 r2`
    if [ "$str_1080p_id" = "$g_id_gc2053" ];then
        JKsh_echo_info "sensor is gc2053"
        touch $G_SENSOR_INFO_PATH/sensor_gc2053
        return 1
    fi

    JKsh_echo_info "sensor id is $str_1080p_id"
    JKsh_echo_warn "isn't 1080p sensor"
    return 0
}

read_720p_sensor()
{
    str_720p_id=`i2c_read_id -f -y 0 w1@0x30 0xa r2`
    if [ "$str_720p_id" = "$g_id_h62" ];then
        JKsh_echo_info "sensor is h62"
        insmod /lib/modules/sensor_h62_mipi.ko
        rmmod ak_isp sensor_h62
        insmod /lib/modules/ak_isp.ko internal_pclk=100000000
        touch $G_SENSOR_INFO_PATH/sensor_h62
        return 1
    fi

    str_720p_id=`i2c_read_id -f -y 0 w1@0x40 0xa r2`
    if [ "$str_720p_id" = "$g_id_h63" ];then
        JKsh_echo_info "sensor is h63"
        touch $G_SENSOR_INFO_PATH/sensor_h63
        return 1
    fi

    JKsh_echo_info "sensor id is $str_720p_id"
    JKsh_echo_warn "isn't 720p sensor"
    return 0
}

read_1080p_sensor
if [ $? -eq 1 ];then
    echo 49 > /sys/class/gpio/unexport
    touch $G_SENSOR_INFO_PATH/sensor_1080p
    exit
fi

read_720p_sensor
if [ $? -eq 1 ];then
    echo 49 > /sys/class/gpio/unexport
    touch $G_SENSOR_INFO_PATH/sensor_720p
    exit
fi

echo 49 > /sys/class/gpio/unexport

