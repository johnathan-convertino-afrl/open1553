# HOW TO... Create a sdcard.
## For: Xilinx arm64 ultrascale systems (zcu102)

This howto will explain the steps needed to put a sdcard together for the zcu102 development board.

Requirements:
* Ubuntu 18.04 (recommened, can be done in other Linux based OS).


### ROOTFS BOOTFS
If you haven't, follow the other two howtos and create the files needed.

  <div style="page-break-after: always;"></div>

### Document Version
* v1.1 - 01/18/20 - Updated markdown formatting.

#### Document History
* ~~v1.0~~ - 12/1/18 - ARM and ARM64 Instructions for Ubuntu
* ~~v0.XX~~ Untested document version.

  <div style="page-break-after: always;"></div>

## Table of Contents
1. [Creating Partitions](#Creating-Partitions)
2. [Copy Data to the SDCARD](#Copy-Data-to-the-SDCARD)
3. [Alternative: Use Analog Devices Image](#Use-Analog-Devices-Image)

  <div style="page-break-after: always;"></div>

### Creating Partitions
[Back to TOC](#Table-of-Contents)

1. Launch gparted and then create two partitions.
    - a fat32 32 MB to 128 MB partition marked bootable, and labeled bootfs.
    - a ext4 partition of any size greater then 4 gigs labeled rootfs.

  <div style="page-break-after: always;"></div>
  
### Copy Data to the SDCARD
[Back to TOC](#Table-of-Contents)

0. Mount the directories, in Ubuntu this may involve reinserting the card after formatting.
1. Copy the bootfs directory files to the bootfs partition on the sdcard.
    - cp -pr /your/path/to/bootfs/* /path/to/sdcard/bootfs/
2. Copy the rootfs directory files to the rootfs partition on the sdcard.
    - sudo cp -pr /your/path/to/rootfs/* /path/to/sdcard/rootfs/
3. Once completed eject the sdcard.
    - IMPORTANT: Make sure to un-mount the SDcard using umount or the GUI. It will take some time since the copy will end before its actually done copying.
4. Insert the SDcard in the zcu102.
    - SW6 switches are[1:4]: on off off off
5. Connect a console to the serial terminal.
    - Console settings: 115200 8n1, hardware flow control: NO, software flow control: NO
    - minicom -D /dev/ttyUSB0 115200
    - If you can't enter input, check if hardware flow control is on.
6. Power up the zcu102, you should see boot messages in the terminal window.

  <div style="page-break-after: always;"></div>

### Use Analog Devices Image
[Back to TOC](#Table-of-Contents)

0. Instead of the above, you can use the analog devices prebuilt sdcard image and copy the needed files into the bootfs (recommened).
    - This will skip the ROOTFS step, all the BOOTFS files are still needed.
1. The Image file is located in this repo under pmod1553/linux/2019_R1-2020_06_22.img.xz
2. Extract the image.
    - unxz 2019_R1-2020_06_22.img.xz
3. Write image to SDCARD.
    - dd if=2019_R1-2020_06_22.img of=/dev/yourDevice status=progress
4. Eject, and remount SDCARD.
5. Copy the bootfs directory files to the bootfs partition on the sdcard.
    - cp -pr /your/path/to/bootfs/* /path/to/sdcard/bootfs/
6. Eject card and enjoy.
