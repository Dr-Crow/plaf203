#!/bin/sh

source link_led_ctrl.sh

JKsh_led_init

while true
do
    if [ -e "/tmp/upgrade_ok" ];then
        # double blink #
        for i in 0 1
        do
            JKsh_led_ctrl 0
            sleep 0.25
            JKsh_led_ctrl 1
            sleep 0.25
        done
        sleep 1
    elif [ -e "/tmp/upgrade_failed" ];then
        JKsh_led_ctrl 0
        sleep 1
    elif [ -e "/tmp/connect_wifi_success" ];then
        JKsh_led_ctrl 1
        sleep 1
    else # connecting network #
        JKsh_led_ctrl 0
        sleep 0.5
        JKsh_led_ctrl 1
        sleep 0.5
    fi
done
