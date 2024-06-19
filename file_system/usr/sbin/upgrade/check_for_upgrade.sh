#!/bin/sh

upgrade_flag_path="/tmp/upgrade_flag_file"

check_linux_version()
{
    u_ver_str=`cat /tmp/version.txt`
    ver_str=`cat /mnt/config/jiake_version.txt | grep "version=" | awk -F "version=" '{print $2}'`
    ver_num=${ver_str:6}
    linux_num=${u_ver_str:6}

    # compare firmware version #
    if [ "$linux_num" -eq "$ver_num" ];then
        echo "no need to upgrade firmware version"
    else
        touch $upgrade_flag_path/linux_need_upgrade
    fi
}

check_mcu_version()
{
    u_ver_str=`cat /tmp/version.txt`
    mcu_num=${u_ver_str:3:2}
    ver_num=`cat /mnt/config/mcu_version.txt`

    if [ ! -e "/mnt/config/mcu_version.txt" ];then
        echo "no mcu version"
        return
    fi

    # compare firmware version #
    if [ "$mcu_num" -eq "$ver_num" ];then
        echo "no need to upgrade mcu version"
    else
        touch $upgrade_flag_path/mcu_need_upgrade
    fi
}

echo 3 > /proc/sys/vm/drop_caches
swapoff /dev/zram0

rm /tmp/user_watching
burn_ok_led.sh upgrade_sys &

echo "mkdir upgrade flag path"
mkdir -p $upgrade_flag_path

echo "tar upgrade package"
tar xf /tmp/upgrade.tar -C /tmp/

echo "rm upgrade.tar"
rm /tmp/upgrade.tar

echo "check MCU and Linux version"
check_mcu_version
check_linux_version

echo "end of check"
touch $upgrade_flag_path/end_of_check
