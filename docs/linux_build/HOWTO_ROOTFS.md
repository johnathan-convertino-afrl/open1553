# HOW TO... Create a root file system
## For: ARM systems

This how-to will explain the steps needed to put a root file system together for the zedboard development board.
Results:

* Ubuntu 18.04 base system.

In this guide we will use the GUI whenever possible. It is possible to do everything via the command line.

Requirements:

* Ubuntu 18.04 (recommended, can be done in other Linux based OS).
* qemu-user-static
* debootstrap

  <div style="page-break-after: always;"></div>

### Document Version
* v1.2 - 01/25/20 - Updated convert root. Added extra root section.

#### Document History
* ~~v1.1~~ - 01/18/20 - Updated markdown formatting.
* ~~v1.0~~ - 12/1/18 - ARM and ARM64 Instructions for Ubuntu
* ~~v0.XX~~ Untested document version.

  <div style="page-break-after: always;"></div>

### Table of Contents
1. [Creating Directories](#Creating-Directories)
2. [Create a root file system in Ubuntu](#Create-a-root-file-system-in-Ubuntu)

  <div style="page-break-after: always;"></div>

### Creating Directories
[Back to TOC](#Table-of-Contents)

* Create three folders.
    - bootfs
    - rootfs
    - git
* Create them in same directory, remember the paths for later usage.

  <div style="page-break-after: always;"></div>

### Create a root file system in Ubuntu
[Back to TOC](#Table-of-Contents)

1. Enter the directory containing your rootfs folder.
2. Run the qemu-debootstrap command to build the arm base system.
    - For ARM64:
        - sudo qemu-debootstrap --arch arm64 bionic rootfs
    - For ARM
        - sudo qemu-debootstrap --arch armhf bionic rootfs
3. Process will build the bionic base system.
4. When completed, chroot into the rootfs directory.
    - sudo chroot rootfs
5. You should now be in the arm filesystem. Check this by checking the Linux architecture.
    - uname -a
    - look for arm in the string that it returns.
6. Add a user to the base system.
    - adduser name_of_user
7. Add user to sudo group
    - usermod -aG sudo name_of_user
8. Set the locale.
    - locale-gen en_US.UTF-8
    - dpkg-reconfigure locales
        - follow the on screen instructions.
9. Exit the chroot.
    - exit
