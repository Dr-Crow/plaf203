#!/bin/sh

sleep 30

g_total_cnt=0
g_last_val=`cat /proc/interrupts | grep video-encoder | awk -F " " '{print $2}'`

while true
do
    g_now_val=`cat /proc/interrupts | grep video-encoder | awk -F " " '{print $2}'`
    # wait 60s #
    if [ $g_total_cnt -eq 6 ];then
        echo "get video failed"
        reboot
    fi

    if [ $g_last_val -eq $g_now_val ];then
        echo -e "\033[37;41mno video\033[0m"
        let g_total_cnt++
    else
        g_total_cnt=0
    fi

    g_last_val=`cat /proc/interrupts | grep video-encoder | awk -F " " '{print $2}'`
    sleep 10
done

