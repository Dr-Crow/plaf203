# Exploring and Hacking the Petlibro Pet Feeder (PLAF203)

This repository contains scripts, notes, and dumps of the Petlibro Pet Feeder model PLAF203.

By utilizing the SD card slot, one can place a bash script named `tmp_test.sh` at the root of the SD card. This script will run with root privileges, allowing us to extract information about the system using this debug feature.

## Gaining Root Access

There are two methods to gain root access to the device without physically opening it. The simpler approach involves checking if the telnet port (21) is open and attempting to connect using the username `root` and password `AK2040jk`.

For those interested in a more detailed explanation of my access method, it involved leveraging the device's boot sequence flow and introducing a custom bash script via the SD card. By placing a bash script named `tmp_test.sh` at the root of the SD card and powering on the device from a powered-off state, the script is executed during boot.

Since we intercept the boot sequence flow, certain considerations are necessary. Initially, when using a bash script from the SD card, the device lacks network connectivity until later in the boot process. We can leverage existing scripts on the device to manually establish network connections. Using the built-in BusyBox command `nc` (netcat), we can create a reverse tunnel. By running netcat on another computer on the network and listening for incoming tunnel requests, modifying `tmp_test.sh` enables us to connect the device to Wi-Fi and establish a temporary reverse tunnel. This grants root access on the computer listening for tunnel requests. However, note that this tunnel is transient; it needs to be re-established if netcat is exited or the device is rebooted.

Through the reverse tunnel, we gain access to the [`/etc/shadow`](/file_system/etc/shadow) file, which contains hashed passwords for users, including root. Tools like hashcat can then be used to crack these hashed passwords.

## Booting Sequence Flow

1. **rcS** - [file_system/etc/init.d/rcS](file_system/etc/init.d/rcS)
   - **inittab** - [file_system/etc/inittab](file_system/etc/inittab) - Controls the init process.

2. **app_init.sh** - [file_system/system/init/app_init.sh](file_system/system/init/app_init.sh)

3. **upgrade_on_sdcard.sh** - [file_system/usr/sbin/upgrade_on_sdcard.sh](file_system/usr/sbin/upgrade_on_sdcard.sh)
   - `tmp_test.sh` will be called if the file exists in `/mnt/config/record`

4. **start_tuya_ipc.sh** - [file_system/usr/sbin/start_tuya_ipc.sh](file_system/usr/sbin/start_tuya_ipc.sh)

## Firmware Update Instructions

Early on in the PLAF203 release, there were reported issues with WiFi on some customers' networks. Due to these issues, Petlibro released instructions on how to manually update the firmware. This gives us insight into the update process and potential access points to the device.

Please refer to the [README.md](/findings/firmware_update/README.md) for detailed instructions.


## Findings

Within the root of this repository, you will encounter several folders containing valuable insights into the Petlibro Pet Feeder (PLAF203) device.

- **file_system**: This directory houses a dump of the device's file system. It includes numerous intriguing bash scripts and binaries that I explored extensively to unravel the device's operations. Please explore it yourself to delve into the inner workings of the device. Certain files such as [tuya_config.txt](/file_system/mnt/config/tuya_config.txt) and [wpa_conf](/file_system/mnt/config/wpa_conf) have been censored to protect sensitive information such as usernames and passwords.

- **findings**: This folder contains dumps of various information about the device, including details about running processes, available executables, NAND partitions, firmware dumps, and more.

- **test_scripts**: Here you will find bash scripts I developed to extract diverse information from the device. While functional, these scripts may require adjustments for specific use cases. They represent initial efforts and are open to contributions via pull requests (PRs) aimed at improving their structure and efficiency.

## Goals

My primary objectives include exposing a local camera feed using protocols like RTSP and enhancing the local API to better control the capabilities of the pet feeder. It appears that some features of the pet feeder may already be accessible via [Home Assistant through the Tuya integration](https://github.com/home-assistant/core/pull/61359).

Regardless, my ultimate goals revolve around making the camera feed accessible and developing an API that seamlessly integrates with Home Assistant.

## Other Resources

While there is a wealth of information available online about similar devices, specific details on this particular device, the Petlibro Pet Feeder (PLAF203), are relatively scarce. When I initially started exploring this device, there were no dedicated articles available. However, I recently came across a blog post discussing interesting findings about this device.

One notable discovery from the blog post is the ability to trigger the device's motor to dispense food using a command like:

```bash
echo -en "\x55\xaa\x03\x01\x00\x01\x01\x05" > /dev/ttySAK1
```


You can read more about this discovery from the author's blog post: [SNHack Attack: How Hackers Could Turn Your Smart Pet Feeder into an All-You-Can-Eat Buffet](https://www.whid.ninja/blog/snhack-attack-how-hackers-could-turn-your-smart-pet-feeder-into-an-all-you-can-eat-buffet)


## Interesting Executables Built In

- [cttyhack](https://boxmatrix.info/wiki/Property:cttyhack) - Provides a program with a controlling tty if possible.

- [login](https://boxmatrix.info/wiki/Property:login_(bbcmd)) - Initiates a new session on the system.

- [netstat](https://boxmatrix.info/wiki/Property:netstat) - Displays networking information.

- [init](https://boxmatrix.info/wiki/Property:init_(bbcmd)) - Provides insights into how BusyBox starts up a system.

- [switch_root](https://boxmatrix.info/wiki/Property:switch_root) - Frees initramfs and switches to another root filesystem.

- [syslogd](https://boxmatrix.info/wiki/Property:syslogd) - System logging daemon.

- [cryptpw](https://boxmatrix.info/wiki/Property:cryptpw) - Prints crypt hashed password.

- [ftpget](https://boxmatrix.info/wiki/Property:ftpget) - Retrieves a remote file via FTP.

- [ftpput](https://boxmatrix.info/wiki/Property:ftpput) - Stores a local file on a remote machine via FTP.

- [hexdump](https://boxmatrix.info/wiki/Property:hexdump) - Displays file contents in hexadecimal, decimal, octal, or ASCII.

- [mkpasswd](https://boxmatrix.info/wiki/Property:mkpasswd) - Prints crypt(3) hashed password.

- [nc](https://boxmatrix.info/wiki/Property:nc) - Allows arbitrary TCP and UDP connections and listens.

- [passwd](https://boxmatrix.info/wiki/Property:passwd_(bbcmd)) - Changes the owner or a user's password.

- [pscan](https://boxmatrix.info/wiki/Property:pscan) - Scans a host and prints all open ports.

- [tcpsvd](https://boxmatrix.info/wiki/Property:tcpsvd) - Creates a TCP socket, binds it to an IP and port, and listens.

- [telnet](https://boxmatrix.info/wiki/Property:telnet) - Connects to a telnet server.

- [tftp](https://boxmatrix.info/wiki/Property:tftp) - Transfers a file from/to a TFTP server.

- [udpsvd](https://boxmatrix.info/wiki/Property:udpsvd) - Creates a UDP socket, binds it to an IP and port, and waits.

- [wget](https://boxmatrix.info/wiki/Property:wget) - Retrieves files via HTTP or FTP.

- [inetd](https://boxmatrix.info/wiki/Property:inetd_(bbcmd)) - Listens for network connections and launches programs.

- [telnetd](https://boxmatrix.info/wiki/Property:telnetd_(bbcmd)) - Telnet server. Handles incoming Telnet connections.

- [tftpd](https://boxmatrix.info/wiki/Property:tftpd) - Transfers a file on a TFTP client's request.

- [uname](https://boxmatrix.info/wiki/Property:uname) - Print system information.

- [df](https://boxmatrix.info/wiki/Property:df) - Report file system disk space usage.

- [mpstat](https://boxmatrix.info/wiki/Property:mpstat) - Report processors related statistics.

- [stat](https://boxmatrix.info/wiki/Property:stat) - Display file or file system status.

- [iostat](https://boxmatrix.info/wiki/Property:iostat) - Report Central Processing Unit (CPU) and Input/Output statistics.

- [blkid](https://boxmatrix.info/wiki/Property:blkid) - Locate/print block device attributes.

- [du](https://boxmatrix.info/wiki/Property:du) - Estimate file space usage.

- [free](https://boxmatrix.info/wiki/Property:free) - Display amount of free and used memory in the system.

- [groups](https://boxmatrix.info/wiki/Property:groups) - Print group memberships for each user.

- [hostid](https://boxmatrix.info/wiki/Property:hostid) - Print the numeric identifier for the current host.

- [id](https://boxmatrix.info/wiki/Property:id) - Print real and effective user and group IDs.

- [lsof](https://boxmatrix.info/wiki/Property:lsof) - List open files.

- [lsusb](https://boxmatrix.info/wiki/Property:lsusb) - List USB devices.

- [top](https://boxmatrix.info/wiki/Property:top) - Display Linux tasks.

- [whoami](https://boxmatrix.info/wiki/Property:whoami) - Print effective username.

