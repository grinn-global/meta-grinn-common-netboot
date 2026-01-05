#!/usr/bin/env bash

NETBOOT_USR=$(whoami)

# --- MODIFY IF NECESSARY ---
export TFTP_PATH="/srv/tftp"
export NFS_ROOTFS_PATH="/srv/nfs"/${NETBOOT_USR}/"rootfs"
export TFTP_KERNEL_BIN_PATH=${NETBOOT_USR}/"image.bin"
export TFTP_DTB_BIN_PATH=${NETBOOT_USR}/"dtb.dtb"
export TFTP_IMAGE_PATH=${NETBOOT_USR}/"SYNAIMG"
# ------

if [ ! -d "${TFTP_PATH}/${NETBOOT_USR}" ]; then
    echo "${TFTP_PATH}/${NETBOOT_USR} doesn't exsists! Creating directory.."
    sudo mkdir -p "${TFTP_PATH}/${NETBOOT_USR}"
fi

if [ ! -d ${NFS_ROOTFS_PATH} ]; then
    echo "${NFS_ROOTFS_PATH} doesn't exsists! Creating directory.."
    sudo mkdir -p ${NFS_ROOTFS_PATH}
fi
