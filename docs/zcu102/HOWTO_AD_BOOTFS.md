# HOW TO... Create a boot file system
## For: Xilinx arm64 ultrascale systems (zcu102)

This howto will explain the steps needed to put a boot file system together for the zcu102 development board.

Results:

* system.bit (Creation of the HDL)
* FSBL (first stage boot loader)
* PMU (Platform Managment Unit)
* ATF (ARM trusted Firmware)
* U-Boot (Second Stage boot loader)
* BOOT.bin (Wrapper for first and second stage bootloader, PMU, and ATF)
* Kernel (Linux Kernel)
* DTB (Device Tree Binary)
* uEnv.txt (Tells uboot how to load files)

In this guide we will use the GUI whenever possible. Everthing can be done via the command line.

Requirements:

* Ubuntu 18.04 (recommened, can be done in other Linux based OS).
* Vivado 2018.3
* aarch64-linux-gnu-
* make
* dtc

  <div style="page-break-after: always;"></div>

### Document Version
* v1.2 - 11/09/20 - Updated vivado version.

#### Document History
* ~~v1.1~~ - 01/18/20 - Updated markdown formatting.
* ~~v1.0~~ - 12/1/18 - Tested working version of the document.
* ~~v0.XX~~ Untested document version.

  <div style="page-break-after: always;"></div>

## Table of Contents
1. [Creating Directories](#Creating-Directories)
2. [Creating HDL](#Creating-HDL)
3. [Startup Xilinx SDK](#Startup-Xilinx-SDK)
4. [Create FSBL](#Create-FSBL)
5. [Create PMU](#Create-PMU)
6. [Create ATF](#Create-ATF)
7. [Build u-boot](#Build-uboot)
8. [Create boot binary](#Create-boot-binary)
9. [Build Linux Kernel](#Build-Linux-Kernel)
10. [Build Device Tree](#Build-Device-Tree)
11. [Create uEnv.txt file](#Create-uEnv-text-file)

### Sources
* [pmod1553 Github repo](https://github.com/johnathan-convertino-afrl/pmod1553.git "pmod1553 Repo")
* [Analog Devices Linux Kernel AFRL Fork Github repo](https://github.com/johnathan-convertino-afrl/linux.git "Analog Devices Linux Kernel AFRL Fork")
* [Xilinx Uboot Github repo](https://github.com/Xilinx/u-boot-xlnx.git "Xilinx uboot")

### References
* [Analog Devivces, Building HDL](https://wiki.analog.com/resources/fpga/docs/build)
* [Analog Devices, how to build for the ZynqMP](https://wiki.analog.com/resources/eval/user-guides/ad-fmcomms2-ebz/software/linux/zynqmp)
* [Analog Devives, Scripted BOOT.bin build](https://raw.githubusercontent.com/analogdevicesinc/wiki-scripts/master/zynqmp_boot_bin/build_zynqmp_boot_bin.sh)
* [Xilinx Wiki Page, zcu102 build](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842156/Fetch+Sources)
* [York.ac.uk, note at end about booti vs bootm](https://wiki.york.ac.uk/display/RTS/ZCU102+Linux)
* [Website with Chatter About uboot/z/i/m issues](https://lists.denx.de/pipermail/u-boot/2015-March/208852.html)

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
    - git checkout release_1553_v1
4. Build the project needed using make.
    - make fmc1553.zcu102 (for fmc1553 board)
    - make fifo_pmod1553.zcu102 (for pmod1553 board)
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
6. The next window will show some available templates. You will be looking for "Zynq MP FSBL". Select it, and click finish.
7. Your FSBL bit file will now generate.

  <div style="page-break-after: always;"></div>

### Create PMU
[Back to TOC](#Table-of-Contents)

1. If you have not opened the SDK yet, follow all of the instructions above in Startup SDK.
2. In the SDK move the cursor to the *File* menu option and click on *File*.
3. This will open a menu, move the cursor to the item *new*.
4. *new* will expand into a new menu, move the cursor and click *Application Projects*.
5. A new window will open, change the following and then click next.
 - Project name: PMU_0
 - Processor   : psu_pmu_0
6. The next window will show some avaiable templates. You will be looking for "ZynqMP PMU Firmware". Select it, and click finish.
7. Your PMU bit file will now generate.
* NOTE: Uses microblaze for compiling. This may not work if not setup correctly.

  <div style="page-break-after: always;"></div>

### Create ATF
[Back to TOC](#Table-of-Contents)

1. If you have not opened the SDK yet, follow all of the instructions above in Startup SDK.
2. In the SDK move the cursor to the *File* menu option and click on *File*.
3. This will open a menu, move the cursor to the item *new*.
4. *new* will expand into a new menu, move the cursor and click *Project*.
5. A new window will open, this will show all the wizards available. In the search box type *ARM*.
6. This should result in only one option being shown, *ARM Trusted Firmware Project*. Select this and click next.
7. A new window will open, change the following and then click finish.
    - Project name: ATF_0
8. Your ATF bit file will now generate.

  <div style="page-break-after: always;"></div>

### Build uboot
[Back to TOC](#Table-of-Contents)

1. Clone the Xilinx Uboot repo to your git folder.
    - git clone https://github.com/Xilinx/u-boot-xlnx.git
2. Enter the u-boot repo
    - cd u-boot-xlnx
3. Checkout the tag that matches your Vivado version.
    - git checkout -b v2018.3 xilinx-v2018.3
4. Set your cross compiler.
    - export CROSS_COMPILE=aarch64-linux-gnu-
5. Configure u-boot for the zcu102.
    - make xilinx_zynqmp_zcu102_rev1_0_defconfig
6. Build uboot.
    - make
7. Once completed, the root of the u-boot repository will contain output files. Rename u-boot to u-boot.elf
    - mv u-boot u-boot.elf

  <div style="page-break-after: always;"></div>
 
### Create boot binary
[Back to TOC](#Table-of-Contents)

1. If you have not opened the SDK yet, follow all of the instructions above in Startup SDK.
2. In the SDK move the cursor to the FSBL_0 project from earlier, select it.
3. Move the cursor to the *Xilinx* menu option and click.
4. This will open a menu, move the cursor and click *Create Boot Image*.
5. A new window will appear. Make sure under *Boot Image Partitions* only (bootload) /some/path/FSBL_0.elf is shown. If anything else is listed, delete it.
6. Click the add button, a new window will appear. Click browse next to the file path input at the top of the window.
7. A file browser will appear, in this window navigate to the PMU_0 project directory. This is located in the Analog Devices HDL repo in the zcu102 project under the *.sdk directory.
8. Once in the root PMU_0 project directory go to into the Debug folder, once there select the file PMU.elf and click ok.
9. Change the following in the add partition window, and then click ok.
    - Partition Type : pmu (loaded by bootrom)
10. The PMU is now added to the BOOT.bin
11. Next we add the ATF, click add again.
12. Again, in the add partition window, click browse next to file path.
13. Again, a file browser will appear, in this window navigate to the ATF_0 project directory. This is located in the Analog Devices HDL repo in the zcu102 project under the *.sdk directory.
14. Once in the root ATF_0 project directory navigate to src/build/zynqmp/debug/bl31 once there select the file bl31.elf and click ok.
15. Change the following in the add partition window, and then click ok.
    - Exception Level  : EL3
    - Enable Trust Zone: Checked
16. The ATF is now added to the BOOT.bin
17. Next we add u-boot, click add again.
18. Again, in the add partition window, click browse next to file path.
19. Again, a file browser will appear, in this window navigate to the Xilinx U-Boot repo. This is located in your git folder named u-boot-xilinx.
20. Once in the root of the Xilinx U-Boot repo select the file u-boot.elf and click ok.
21. Change the following in the add partition window, and then click ok.
    - Exception Level : EL2
22. The u-boot file is now added to BOOT.bin
23. Change the output path of the output path field by selecting browse, then pointing the output to the bootfs directory created earlier.
24. Click create image, if it asks about overwritting a bif file, click ok, and generate BOOT.bin.
25. BOOT.bin will now be generated in the bootfs folder.

  <div style="page-break-after: always;"></div>

### Build Linux Kernel
[Back to TOC](#Table-of-Contents)

1. Clone the Analog Devices Linux Kernel AFRL fork repo to your git folder.
    - git clone https://github.com/johnathan-convertino-afrl/linux.git
2. Enter the Linux Kernel Repo
    - cd linux
3. Checkout the branch that matches your HDL version.
    - git checkout release_1553_v1
4. Set your cross compiler
    - export CROSS_COMPILE=aarch64-linux-gnu-
5. Set you architecture
    - export ARCH=arm64
6. Setup the configuration.
    - make adi_zynqmp_defconfig
7. Build the kernel.
    - make -j$(nproc)
8. Once completed, copy the kernel to your bootfs folder.
    - cp arch/arm64/boot/Image /path/to/your/bootfs

  <div style="page-break-after: always;"></div>
 
### Build Device Tree
[Back to TOC](#Table-of-Contents)

1. If you haven't built the kernel yet, follow the directions above in Build Linux Kernel.
2. Generate the device tree binary.
    - make xilinx/zynqmp-zcu102-fmc1553.dtb (for fmc1553 board)
    - make xilinx/zynqmp-zcu102-pmod1553.dtb (for pmod1553 board)
3. Copy and rename the device tree binary to the bootfs folder.
    - cp arch/arm/boot/dts/zynqmp-zcu102-fmc1553.dtb path/to/your/bootfs/devicetree.dtb

  <div style="page-break-after: always;"></div>

### Create uEnv text file
[Back to TOC](#Table-of-Contents)

1. Create a text file named *uEnv.txt* in your bootfs folder that contains the following:

```
kernel_image=Image
kernel_load_address=0x3000000
devicetree_image=devicetree.dtb
devicetree_load_address=0x2A00000
bitfile=system_top.bit
bitfile_load_address=0x5000000

uenvcmd=run adi_sdboot

adi_sdboot=echo Starting Linux... && fatload mmc 0 ${bitfile_load_address} ${bitfile} && fpga loadb 0 ${bitfile_load_address} $filesize && fatload mmc 0 ${kernel_load_address} ${kernel_image} && fatload mmc 0 ${devicetree_load_address} ${devicetree_image} && booti ${kernel_load_address} - ${devicetree_load_address}

bootargs=earlycon=cdns,mmio,0xFF000000,115200n8 console=ttyPS0,115200n8

root=/dev/mmcblk0p2 rw rootwait cma=128M

```

