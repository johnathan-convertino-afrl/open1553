# open_1553
## Respository of open source 1553 designs for the pmod_1553 device.
---

   author: Jay Convertino   
   
   date: 2021.07.29  
   
   details: FPGA devices used via a PMOD mil-std-1553 electrical interface device to decode and encode 1553 transmissions.  
   
   license: Various   
   
---

![logo_img](./logo.png)

### Requirements
#### HDL
  * Vivado 2018.3.1
  * Icarus
#### Software
  * GCC
  * DTC
  
### USAGE
#### hardware directory

Simply open the KiCAD project file in hardware/pmod/kicad. This will allow you to  
look over the schematic and board design. You may then export it to whatever format   
needed for your PCB manufacturing process.  

#### HDL

The HDL build systems requires both Vivado and Icarus if you run a make all.   
If you don't make all and make individual projects or cores you do not need icarus.

Example... make uart_pmod1553.arty-a7-35... will run only vivado to generate the target.   

See IP core (library folder) for details on simulation and usage.

#### linux

axisfifo is a repository that contains the linux kernel driver source code for the   
Xilinx Axis FIFO ip. This is only needed for the zedboard design. Build this against   
the kernel from Analog Devices github repo tagged 2019_R1.   

zed is a folder of files to generate the boot binary. You may use the bootgen_files   
to create a new BOOT.bin. BOOT.bin is a complete build for the 2019_R1 release that can be  
used on the zedboard as is with the Analog Devices SDCARD image. The device three is also  
included in the same folder.    

The reference base image file is included for SDCARD imaging. (2019_R1-2020_06_22.img.xz)

### DIRECTORIES
#### hardware

Contains hardware design and information for the pmod_1553 device.   
This design is done in KiCAD version 5.x.   

#### HDL

Contains FPGA files for pmod_1553 projects. It contains libraries that are the  
actual code for IP cores, and projects that generate for target boards.  
Currently Supported:   

  * Digilent Arty 35T (UART DEVICE)
  * Digilent CMOD S7  (UART DEVICE)
  * Zedboard (Xilinx FIFO)

The original source for the HDL build system is from Analog Devices, all copyrights   
are there own and I claim no ownership of their code.

The original code has been altered and simulation capibility added.

HDL code built with Vivado 2018.3.1

#### linux

Contains code for the Zedboard Xilinx FIFO project. This project uses the    
Analog Devices HDL base and its SDCARD image. The axisfifo folder contains the  
opensource driver for the xilinx axis fifo ip core. Zed contains the folder with   
needed files for generating boot files, and a device tree with the correct settings.  
