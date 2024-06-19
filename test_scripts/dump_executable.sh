#!/bin/sh

FOLDER="/mnt/config/record"

touch $FOLDER/executables.txt

ls -lah /system/bin/ >> $FOLDER/executables.txt

echo "/usr/sbin/upgrade/" >> $FOLDER/executables.txt
ls -lah /usr/sbin/upgrade/ >> $FOLDER/executables.txt

echo "" >> $FOLDER/executables.txt
echo "" >> $FOLDER/executables.txt
echo "/bin/" >> $FOLDER/executables.txt
ls -lah /bin/ >> $FOLDER/executables.txt

echo "" >> $FOLDER/executables.txt
echo "" >> $FOLDER/executables.txt
echo "/sbin/" >> $FOLDER/executables.txt
ls -lah /sbin/ >> $FOLDER/executables.txt

echo "" >> $FOLDER/executables.txt
echo "" >> $FOLDER/executables.txt
echo "/usr/bin/" >> $FOLDER/executables.txt
ls -lah /usr/bin/ >> $FOLDER/executables.txt

echo "" >> $FOLDER/executables.txt
echo "" >> $FOLDER/executables.txt
echo "/usr/sbin/" >> $FOLDER/executables.txt
ls -lah /usr/sbin/ >> $FOLDER/executables.txt

# ls -lah /tmp/bin/ >> $FOLDER/executables.txt
# ls -lah /tmp/tutk_test/ >> $FOLDER/executables.txt