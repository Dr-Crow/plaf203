#!/bin/sh
if [ $# -ne 2 ];
then
    echo ''
    echo 'fail ! Please enter UUID and AUTHKEY in order'
    echo ''
    exit
fi

OLD_UUID=`cat /mnt/config/tuya_config.txt | grep UUID | awk -F "UUID=" '{print $2}'`
NEW_UUID=$1
sed -i s/$OLD_UUID/$NEW_UUID/g /mnt/config/tuya_config.txt
echo 'NOW UUID='$(cat /mnt/config/tuya_config.txt | grep UUID | awk -F "UUID=" '{print $2}')

OLD_AUTHKEY=`cat /mnt/config/tuya_config.txt | grep AUTHKEY | awk -F "AUTHKEY=" '{print $2}'`
NEW_AUTHKEY=$2
sed -i s/$OLD_AUTHKEY/$NEW_AUTHKEY/g /mnt/config/tuya_config.txt
echo 'NOW AUTHKEY='$(cat /mnt/config/tuya_config.txt | grep AUTHKEY | awk -F "AUTHKEY=" '{print $2}')
