#!/bin/sh

wget_cnt=0
file_path="/tmp"
test_folder="tutk_test/"
product_test_tar="tutk_test.tar"
burn_uuid_tool="burn_uuid"
http_ip_and_port="http://192.168.7.11:8088"
http_server_addr="$http_ip_and_port/V330/$PRODUCT_MODE"

download_test_tar()
{
    while true
    do
        echo "wget tutk test tar"
        # download test tar #
        wget -t 3 -T 30 -P $file_path $http_server_addr/$product_test_tar
        if [ $? = 0 ];then
            echo "wget test tar ok"
            break
        else
            echo "wget test tar failed"
            rm $file_path/$product_test_tar
        fi

        let wget_cnt++
        if [ "$wget_cnt" -ge 3 ];then
            echo "reboot system"
            reboot
        fi
    done
}

download_burn_uuid_tool()
{
    while true
    do
        echo "wget burn tool"
        # download test tar #
        wget -t 3 -T 30 -P $file_path $http_server_addr/$burn_uuid_tool
        if [ $? = 0 ];then
            echo "wget tool ok"
            break
        else
            echo "wget tool failed"
            rm $file_path/$burn_uuid_tool
        fi

        let wget_cnt++
        if [ "$wget_cnt" -ge 3 ];then
            echo "reboot system"
            reboot
        fi
    done
}

# cd file path #
cd $file_path

if [ "$1" = "burn_uuid" ];then
    product_name=`cat /mnt/config/jiake_version.txt | grep PID | awk -F "PID=" '{print $2}'`
    download_burn_uuid_tool
    chmod 777 burn_uuid
    $file_path/burn_uuid $product_name
else
    download_test_tar
    tar xf $product_test_tar
    chmod 777 -R $test_folder
fi

