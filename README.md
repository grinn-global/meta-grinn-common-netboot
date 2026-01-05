# Network Boot and Remote RootFS

## Overview

During kernel development, it’s often more efficient to avoid reflashing
the board every time a new kernel image is built.
Instead, the kernel can be loaded directly over the network,
greatly speeding up the test cycle.

Using a remote (NFS-mounted) root filesystem
is also extremely helpful during board bring-up and debugging.
It allows developers to make changes to the system files
instantly on the host machine without needing to rebuild
or reflash the target device, providing a faster and more flexible
development workflow.

## Boot Flow

```
                  ----------------------                   ---------------
                  -    HOST PC tftp    -                   - HOST PC nfs -
   ----------     ----------------------     ---------     ---------------
   - U-Boot - --> - Kernel image + dtb - --> - Linux - --> -   rootfs   -     
   ----------     ----------------------     ---------     ---------------
```

## Host setup

### Server folder
Create dedicated directories for TFTP and NFS files
```bash
sudo mkdir -p /srv/tftp
sudo mkdir -p /srv/nfs
```

### TFTP
Install TFTP server
```bash
sudo apt-get install tftpd-hpa
```

Confirm TFTP sever settings
```bash
sudo vim /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure"
```

Start TFTP server
```bash
sudo systemctl enable tftpd-hpa
sudo systemctl start tftpd-hpa
```

### NFS
Install NFS server
```bash
sudo apt install nfs-kernel-server
```
Confirm NFS sever settings
```bash
sudo vim /etc/exports

/srv/nfs *(rw,nohide,insecure,no_subtree_check,sync,no_root_squash)
```
If neccesary, restart NFS server to apply new settings
```bash
sudo systemctl restart nfs-kernel-server
```

---

## Yocto Configuration

### Configuration variables
These variables are used to configure the board for network boot:
- `NETBOOT_SERVER_IP` - IP address of the host providing NFS and TFTP services
- `NFS_ROOTFS_PATH` - NFS export path used as the root filesystem
- `TFTP_KERNEL_BIN_PATH` - Path to the kernel image served by TFTP
- `TFTP_DTB_BIN_PATH` - Path to the device tree blob served by TFTP
- `TFTP_IMAGE_PATH` - Path to the SYNAIMG folder for TFTP flash

### Build
```bash
source meta-grinn-astra/meta-grinn-astra-netboot/scripts/setup.sh

KAS_MACHINE=grinn-astra-1680-ada \
kas-container \
  --runtime-args "
    -e NETBOOT_SERVER_IP=XXX.XXX.XXX.XXX
    -e NFS_ROOTFS_PATH=${NFS_ROOTFS_PATH}
    -e TFTP_KERNEL_BIN_PATH=${TFTP_KERNEL_BIN_PATH}
    -e TFTP_DTB_BIN_PATH=${TFTP_DTB_BIN_PATH}
    -e TFTP_IMAGE_PATH=${TFTP_IMAGE_PATH}
  " \
  build \
  meta-grinn-astra/kas/default.yml:meta-grinn-astra/kas/netboot.yml
```

### Sync
Update TFTP and NFS contents
```bash
meta-grinn-astra/meta-grinn-astra-netboot/scripts/sync.sh
```

## Usage
Netboot flow is controlled via U-Boot environment:

### Enable booting via NFS
```bash
setenv netboot 1
saveenv
reset
```

### Restore default eMMC boot flow
```bash
env delete netboot
saveenv
reset
```

### Optional: TFTP eMMC flash (alternative to USB flashing)
```bash
run tftp_flash
```
