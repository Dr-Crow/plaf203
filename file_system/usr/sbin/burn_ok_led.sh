#!/bin/sh

source link_led_ctrl.sh

JKsh_led_init

if [ "$1" = "upgrade_sys" ];then
    while true
    do
        JKsh_led_ctrl 0
        sleep 0.08
        JKsh_led_ctrl 1
        sleep 0.08
    done
else
    while true
    do
        for i in 0 1 2; do
            JKsh_led_ctrl 0
            sleep 0.1
            JKsh_led_ctrl 1
            sleep 0.1
        done
        sleep 1
    done
fi

