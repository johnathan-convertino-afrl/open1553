# HOW TO... Create a boot file system
## For: Xilinx arm zynq7 (Zedboard)

This how-to will explain the steps needed to put a boot file system together for the zedboard development board.

Results:

* system.bit (Creation of the HDL)
* FSBL (first stage boot loader)
* U-Boot (Second Stage boot loader)
* BOOT.bin (Wrapper for first and second stage bootloader, PMU, and ATF)
* Kernel (Linux Kernel)
* DTB (Device Tree Binary)
* uEnv.txt (Tells uboot how to load files)

In this guide I will use the GUI whenever possible. Everthing can be done via the command line.

Requirements:

* Ubuntu 18.04 (recommended, can be done in other Linux based OS).
* Vivado 2017.4
* arm-linux-gnueabi-
* make
* dtc

  <div style="page-break-after: always;"></div>

### Document Version
* v1.1 - 01/18/20 - Updated markdown formatting.

#### Document History
* ~~v1.0~~ - 12/1/18 - Tested working version of the document.
* ~~v0.XX~~ Untested document version.

  <div style="page-break-after: always;"></div>

## Table of Contents
1. [Creating Directories](#Creating-Directories)
2. [Creating HDL](#Creating-HDL)
3. [Startup Xilinx SDK](#Startup-Xilinx-SDK)
4. [Create FSBL](#Create-FSBL)
5. [Build u-boot](#Build-uboot)
6. [Create boot binary](#Create-boot-binary)
7. [Build Linux Kernel](#Build-Linux-Kernel)
8. [Build Device Tree](#Build-Device-Tree)
9. [Create uEnv.txt file](#Create-uEnv-text-file)
10. [Create BOOT.scr file](#Create-BOOT-scr-file)

### Sources
* [pmod1553 Github repo](https://github.com/johnathan-convertino-afrl/pmod1553.git "pmod1553 Repo")
* [Analog Devices Linux Kernel AFRL Fork Github repo](https://github.com/johnathan-convertino-afrl/linux.git "Analog Devices Linux Kernel AFRL Fork")
* [Xilinx Uboot Github repo](https://github.com/Xilinx/u-boot-xlnx.git "Xilinx uboot")

### References
* [Analog Devivces, Building HDL](https://wiki.analog.com/resources/fpga/docs/build)
* [Analog Devices, how to build for the ZynqMP](https://wiki.analog.com/resources/eval/user-guides/ad-fmcomms2-ebz/software/linux/zynqmp)
* [Analog Devives, Scripted BOOT.bin build](https://raw.githubusercontent.com/analogdevicesinc/wiki-scripts/master/zynqmp_boot_bin/build_zynqmp_boot_bin.sh)
* [Xilinx Wiki Page, zcu102 build](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842156/Fetch+Sources)

  <div style="page-break-after: always;"></div>

### Creating Directories
[Back to TOC](#Table-of-Contents)

* Create three folders.
    - bootfs
    - rootfs
    - git
* Create them in the same directory, remember the paths for later usage.

  <div style="page-break-after: always;"></div>

### Creating HDL
[Back to TOC](#Table-of-Contents)

1. Clone the pmod1553 repo to your git folder.
    - git clone https://github.com/johnathan-convertino-afrl/pmod1553.git
2. Enter the HDL repo
    - cd pmod1553/HDL
3. Checkout the HDL repo that matches your version of vivado (see root readme for release to vivado versioning).
    - git checkout release_v1
4. Build the project needed using make.
    - make fifo1553.zedboard
5. Wait for make to finish executing the build.
6. Open the HDL project with Vivado.
    - This isn't really needed, the bit file already exits, we do this for GUI usage only.
7. Once opened, go to the *File* menu option and click on *File*.
8. This will open a menu, move the cursor to the item *export*.
9. *export* will expand into a new menu, move the cursor and click *export hardware*.
10. A new window will open, click the box next to *include bitstream*. It should now have a check.
11. Click OK, this will export the bitsream to a local project for SDK use later.
12. Repeat steps 7 to 8.
13. Export will expand into a new menu, move the cursor and click *export bitstream*.
14. A file browser will open, navigate to your bootfs folder and save the bit file as 'system_top.bit'.
15. Keep Vivado open, you will need it agian.

  <div style="page-break-after: always;"></div>

### Startup Xilinx SDK
[Back to TOC](#Table-of-Contents)

1. If you have not opened your HDL project yet, follow all of the instructions above in Creating HDL.
2. In Vivado, go to the *File* menu option and click on *File*.
3. This will open a menu, move the cursor to the item *Launch SDK*.
4. This will open a new window, leave everything at default and click ok.
5. The SDK will now launch, leave it open for the next steps.

  <div style="page-break-after: always;"></div>

### Create FSBL
[Back to TOC](#Table-of-Contents)

1. If you have not opened the SDK yet, follow all of the instructions above in Startup SDK.
2. In the SDK move the cursor to the *File* menu option and click on *File*.
3. This will open a menu, move the cursor to the item *new*.
4. *new* will expand into a new menu, move the cursor and click *Application Projects*.
5. A new window will open, change the following and then click next.
    - Project name: FSBL_0
6. The next window will show some available templates. You will be looking for "Zynq FSBL". Select it, and click finish.
7. Your FSBL bit file will now generate.

  <div style="page-break-after: always;"></div>

### Build uboot
[Back to TOC](#Table-of-Contents)

1. Clone the Xilinx Uboot repo to your git folder.
    - git clone https://github.com/Xilinx/u-boot-xlnx.git
2. Enter the u-boot repo
    - cd u-boot-xlnx
3. Checkout the tag that matches your Vivado version.
    - git checkout -b v2018.3 xilinx-v2018.3
    - The above is the last version that works with uEnv.txt, you've been warned.
4. Set your cross compiler.
    - export CROSS_COMPILE=arm-linux-gnueabi-
5. Configure u-boot for the zed.
    - make zynq_zed_defconfig
6. Build uboot.
    - make
7. Once completed, the root of the u-boot repository will contain output files. u-boot.elf is the one you need.

  <div style="page-break-after: always;"></div>
 
### Create boot binary
[Back to TOC](#Table-of-Contents)

1. If you have not opened the SDK yet, follow all of the instructions above in Startup SDK.
2. In the SDK move the cursor to the FSBL_0 project from earlier, select it.
3. Move the cursor to the *Xilinx* menu option and click.
4. This will open a menu, move the cursor and click *Create Boot Image*.
5. A new window will appear. Make sure under *Boot Image Partitions* only (bootload) /some/path/FSBL_0.elf is shown. If anything else is listed, delete it.
6. Click the add button, a new window will appear. Click browse next to the file path input at the top of the window.
7. A file browser will appear, in this window navigate to the Xilinx U-Boot repo. This is located in your git folder named u-boot-xilinx.
8. Once in the root of the Xilinx U-Boot repo select the file u-boot.elf and click ok.
9. The u-boot file is now added to BOOT.bin
10. Change the output path of the output path field by selecting browse, then pointing the output to the bootfs directory created earlier.
11. Click create image, if it asks about overwritting a bif file, click ok, and generate BOOT.bin.
12. BOOT.bin will now be generated in the bootfs folder.

  <div style="page-break-after: always;"></div>

### Build Linux Kernel
[Back to TOC](#Table-of-Contents)

1. Clone the Analog Devices Linux Kernel repo to your git folder.
    - git clone https://github.com/analogdevicesinc/linux
2. Enter the Linux Kernel Repo
    - cd linux
3. Checkout the branch that matches your HDL version.
    - git checkout release_1553_v1 
4. Set your cross compiler
    - export CROSS_COMPILE=arm-linux-gnueabi-
5. Set you architecture
    - export ARCH=arm
6. Setup the configuration.
    - make zynq_xcomm_adv7511_defconfig
7. Build the kernel.
    - make -j$(nproc) uImage UIMAGE_LOADADDR=0x8000
8. Once completed, copy the kernel to your bootfs folder.
    - cp arch/arm/boot/uImage /path/to/your/bootfs

  <div style="page-break-after: always;"></div>
 
### Build Device Tree
[Back to TOC](#Table-of-Contents)

1. If you haven't built the kernel yet, follow the directions above in Build Linux Kernel.
2. Generate the device tree binary.
    - make zynq-zed-adv7511-pmod1553.dtb
3. Copy and rename the device tree binary to the bootfs folder.
    - cp arch/arm/boot/dts/zynq-zed-adv7511-pmod1553.dtb /path/to/your/bootfs/devicetree.dtb

  <div style="page-break-after: always;"></div>

### Create uEnv text file.
[Back to TOC](#Table-of-Contents)

This is the old method, this only works with older versions of uboot (2018.3 and below).

1. Create a text file named *uEnv.txt* in your bootfs folder that contains the following:

```
kernel_image=uImage
kernel_load_address=0x3000000
devicetree_image=devicetree.dtb
devicetree_load_address=0x2A00000
bitfile=base_system.bit
bitfile_load_address=0x5000000

uenvcmd=run adi_sdboot
adi_sdboot=echo Starting Linux... && fatload mmc 0 
${bitfile_load_address} ${bitfile} && fpga loadb 0 ${bitfile_load_address} 
$filesize && fatload mmc 0 ${kernel_load_address} ${kernel_image} && 
fatload mmc 0 ${devicetree_load_address} ${devicetree_image} && 
bootm ${kernel_load_address} - ${devicetree_load_address}

bootargs=console=ttyPS0,115200n8 root=/dev/mmcblk0p2 rw rootwait

```
