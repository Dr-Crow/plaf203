#!/bin/sh

if [ $# -ne 1 ];then
    echo '\n$0 pid\n'
    exit
fi

OLD_PID=`cat /mnt/config/oem_pid.txt | grep PID | awk -F "PID=" '{print $2}'`
NEW_PID=$1
sed -i s/$OLD_PID/$NEW_PID/g /mnt/config/oem_pid.txt
echo 'NOW PID='$(cat /mnt/config/oem_pid.txt | grep PID | awk -F "PID=" '{print $2}')
