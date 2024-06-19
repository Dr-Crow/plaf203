#!/bin/sh

FOLDER="/mnt/config/record"

mkdir -p $FOLDER/file_system/

mkdir -p $FOLDER/file_system/bin
mkdir -p $FOLDER/file_system/dev
mkdir -p $FOLDER/file_system/etc
mkdir -p $FOLDER/file_system/lib
# mkdir -p $FOLDER/file_system/mnt
mkdir -p $FOLDER/file_system/opt
mkdir -p $FOLDER/file_system/proc
mkdir -p $FOLDER/file_system/root
mkdir -p $FOLDER/file_system/run
mkdir -p $FOLDER/file_system/sbin
mkdir -p $FOLDER/file_system/sys
mkdir -p $FOLDER/file_system/system
mkdir -p $FOLDER/file_system/tmp
mkdir -p $FOLDER/file_system/usr
mkdir -p $FOLDER/file_system/var

# cp -a / $FOLDER/file_system/


ls -lah / > $FOLDER/ls.txt
touch $FOLDER/copy.txt

cp -a /bin/* $FOLDER/file_system/bin
echo "copied bin" >> $FOLDER/copy.txt

cp -a /etc/* $FOLDER/file_system/etc
echo "copied etc" >> $FOLDER/copy.txt

cp -a /opt/* $FOLDER/file_system/opt
echo "copied opt" >> $FOLDER/copy.txt

cp -a /root/* $FOLDER/file_system/root
echo "copied root" >> $FOLDER/copy.txt

cp -a /run/* $FOLDER/file_system/run
echo "copied run" >> $FOLDER/copy.txt

cp -a /sbin/* $FOLDER/file_system/sbin
echo "copied sbin" >> $FOLDER/copy.txt

cp -a /sys/* $FOLDER/file_system/sys
echo "copied sys" >> $FOLDER/copy.txt

cp -a /system/* $FOLDER/file_system/system
echo "copied system" >> $FOLDER/copy.txt

cp -a /tmp/* $FOLDER/file_system/tmp
echo "copied tmp" >> $FOLDER/copy.txt

cp -a /usr/* $FOLDER/file_system/usr
echo "copied usr" >> $FOLDER/copy.txt

cp -a /var/* $FOLDER/file_system/var
echo "copied var" >> $FOLDER/copy.txt



cp -a /lib/* $FOLDER/file_system/lib
echo "copied lib" >> $FOLDER/copy.txt

cp -a /dev/* $FOLDER/file_system/dev
echo "copied dev" >> $FOLDER/copy.txt

cp -a /proc/* $FOLDER/file_system/proc
echo "copied proc" >> $FOLDER/copy.txt