PREBOOT_ENV ?= "\
show_logo\
"
BOOTCOMMAND ?= "\
if env exists netboot; then run netboot_boot; else bootmmc; fi\
"
SRV_IP_ENV ?= "\
env exists srv_ip || \
setenv srv_ip ${NETBOOT_SERVER_IP}\
"
TFTP_IMAGE_ENV ?= "\
env exists tftp_image_path || \
setenv tftp_image_path ${TFTP_IMAGE_PATH}\
"
TFTP_KERNEL_ENV ?= "\
env exists tftp_kernel || \
setenv tftp_kernel ${TFTP_KERNEL_BIN_PATH}\
"
TFTP_DTB_ENV ?= "\
env exists tftp_dtb || \
setenv tftp_dtb ${TFTP_DTB_BIN_PATH}\
"
NFS_ENV ?= "\
env exists nfs_rootfs || \
setenv nfs_rootfs ${NFS_ROOTFS_PATH}\
"
NETBOOT_BOOT_ENV ?= "\
env exists netboot_boot || \
setenv netboot_boot \
'setenv bootargs \${bootargs_net}; run boot_net'\
"
BOOTARGS_ENV ?= "\
setenv bootargs_net \
console=ttyS0,115200 \
root=/dev/nfs rw nfsroot=\${srv_ip}:\${nfs_rootfs},v3,tcp \
ip=dhcp \
rootwait \
avio.fastlogo_status=104500 cma=524288000@1556086784 \
"
NETBOOT_ENV ?= "\
env exists boot_net || \
setenv boot_net \
'net_init;\
dhcp;\
setenv serverip \${srv_ip};\
setenv skip_fdt_update 2;\
setenv loadaddr 0x7c00000;\
setenv dtbaddr 0x47f1000;\
tftpboot \${loadaddr} \${tftp_kernel};\
tftpboot \${dtbaddr} \${tftp_dtb};\
booti \${loadaddr} - \${dtbaddr}'\
"
TFTP_FLASH_ENV ?= "\
env exists tftp_flash || \
setenv tftp_flash \
'net_init;\
dhcp;\
setenv serverip \${srv_ip};\
tftp2emmc \${tftp_image_path}'\
"
