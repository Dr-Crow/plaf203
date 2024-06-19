#!/bin/sh

SD_FOLDER="/mnt/config/record"
FINDINGS_FOLDER="$SD_FOLDER/finding"

# Make Findings Folder
mkdir -p $FINDINGS_FOLDER

# Functions
run_command_and_log() 
{
    command=$1
    echo "Running Command: $command\n" >> $FINDINGS_FOLDER/basic_info.txt
    $command >> $FINDINGS_FOLDER/basic_info.txt
    echo "\n" >> $FINDINGS_FOLDER/basic_info.txtf
}

# Get Information on System
touch $FINDINGS_FOLDER/running_env.txt
printenv > $FINDINGS_FOLDER/running_env.txt

touch $FINDINGS_FOLDER/basic_info.txt

run_command_and_log "uname -a"
run_command_and_log "df -h"
run_command_and_log "whoami"
run_command_and_log "groups"
run_command_and_log "hostid"
run_command_and_log "id"
run_command_and_log "lsof"
run_command_and_log "mpstat"
run_command_and_log "stat"
run_command_and_log "iostat"
run_command_and_log "blkid"
run_command_and_log "free"
run_command_and_log "lsusb"
run_command_and_log "top -b -n 1"
run_command_and_log "cat /proc/cpuinfo"
run_command_and_log "cat /proc/mtd"