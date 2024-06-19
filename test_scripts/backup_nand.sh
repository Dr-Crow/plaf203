#!/bin/sh
echo "XXXXXXXXXXXXXXX BACKUP /proc/mtd XXXXXXXXXXXX"
cat /proc/mtd

# Variables
SD_FOLDER="/mnt/config/record"
 
cat /proc/mtd | tail -n+2 | while read; do
    MTD_DEV=$(echo ${REPLY} | cut -f1 -d:)
    MTD_NAME=$(echo ${REPLY} | cut -f2 -d\")
    echo "Backing up ${MTD_DEV} (${MTD_NAME})"
    # It's important that the remote command only prints the actual file
    # contents to stdout, otherwise our backup files will be corrupted. Other
    # info must be printed to stderr instead. Luckily, this is how the dd
    # command already behaves by default, so no additional flags are needed.
    dd if="/dev/${MTD_DEV}ro" > "${SD_FOLDER}/${MTD_DEV}_${MTD_NAME}.backup" || die "dd ${MTD_DEV}ro failed, aborting..."
done