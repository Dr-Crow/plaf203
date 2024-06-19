#!/bin/sh
if [ $# -ne 1 ];
then
    echo ''
    echo 'fail ! burn_ethaddr_mac.sh MAC'
    echo ''
    exit
fi

OLD_MAC=`cat /mnt/config/ucheck_mac.txt | grep MAC | awk -F "MAC=" '{print $2}'`
NEW_MAC=$1
sed -i s/$OLD_MAC/$NEW_MAC/g /mnt/config/ucheck_mac.txt
echo 'NOW MAC='$(cat /mnt/config/ucheck_mac.txt | grep MAC | awk -F "MAC=" '{print $2}')
