# This is the documents repo for the SoC FPGA build process.

These files are all written in markdown so they can be viewed in any text editor. 
When viewed in appropriate viewer the files will be formatted.

### Target
These documents target SoC FPGA builds for Xilinx and Intel. In this directory
with this readme are general files applicable to both platforms. Primarily all of the
information deals with how to install Linux with a base Analog Devices HDL load. If there
is another HDL load it will have a seperate document in the targets folder.

### Task List
- [x] Document Xilinx ARM64 build chain     (zcu102).
- [x] Document Xilinx ARM build chain       (zedboard).

### Document Repo Version
* v1.5 - 01/18/20 - Updated markdown formatting.

#### Document History
* ~~v1.4~~ - 12/20/19 - AFRL_FDL documents added.
* ~~v1.3~~ - 12/18/19 - Added zedboard flash/FIT build.
* ~~v1.2~~ - 12/14/18 - Completed zedboard build docs.
* ~~v1.1~~ - 12/10/18 - Added rocketboards HDL for a10soc
* ~~v1.0~~ - 12/01/18 - First version with Xilinx and Intel ARM64 documentation.
* ~~v0.XX~~ Development version

### Markdown Uses
* Wiki's
* PDF Generation
* GIT repos

### Files
1. ROOT
    - HOWTO_ROOTFS.md (how to create a Ubuntu 18.04 root file system in Ubuntu)
    - HOWTO_CREATE_SDCARD.md (How to copy bootfs and rootfs to the SDCARD)
2. ROOT/zcu102
    - HOWTO_AD_BOOTFS.md (How to create boot files for the zcu102 dev board)
3. ROOT/zedboard
    - HOWTO_AD_BOOTFS.md (How to create Analog Devices boot files for the zedboard)
    
#### Recomended Document Order
1. HOWTO_ROOTFS.md (can be skipped, see HOWTO_CREATE_SDCARD.md for details).
2. HOWTO_AD_BOOTFS.md
3. HOWTO_CREATE_SDCARD.md

