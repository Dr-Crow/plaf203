#!/bin/sh

while true
do
    if [ -e "/tmp/dev_running" ];then
        rm /tmp/*
        touch /tmp/dev_running
    else
        rm /tmp/*
    fi
    killall wifi_status_monitor.sh
    killall wifi_mode_switch.sh
    echo "reset ak_tuya_ipc"
    ak_tuya_ipc
done
