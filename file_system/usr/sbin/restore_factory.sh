#!/bin/sh

# killall process #
free_memory.sh

echo "reset wifi config"
rm /mnt/config/wpa_conf

echo "rm /mnt/config/tuya_enckey.db"
rm /mnt/config/tuya_enckey.db

echo "rm /mnt/config/tuya_user.db"
rm /mnt/config/tuya_user.db

echo "rm /mnt/config/tuya_user.db_bak"
rm /mnt/config/tuya_user.db_bak


if [ "$1" = "wifi_mode" ];then
    echo "wifi mode swtich"
else
    echo "cp /usr/ipcam/bak/*.ini /mnt/config/"
    cp /usr/ipcam/bak/*.ini /mnt/config/

    echo "touch /mnt/config/no_network"
    touch /mnt/config/no_network

    echo "rm /mnt/config/audio_record_file.pcm"
    rm /mnt/config/audio_record_file.pcm

    echo "rm /mnt/config/save_last_date.txt"
    rm /mnt/config/save_last_date.txt

    echo "init all config"
    rm /mnt/config/dp_file_flag/*

    echo "init motion detect sensitivity"
    touch /mnt/config/dp_file_flag/md_low_sensitivity_file

    echo "touch /mnt/config/dp_file_flag/on_osd_file"
    if [ ! -e "/mnt/config/dp_file_flag/on_osd_file" ];then
        touch /mnt/config/dp_file_flag/on_osd_file
    fi

    echo "touch /mnt/config/dp_file_flag/on_light_led_file"
    if [ ! -e "/mnt/config/dp_file_flag/on_light_led_file" ];then
        touch /mnt/config/dp_file_flag/on_light_led_file
    fi
fi

#system reboot
reboot
