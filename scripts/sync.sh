#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source ${SCRIPT_DIR}/setup.sh

if [ -n "$1" ]; then
    YOCTO_DIR=(${SCRIPT_DIR}/../../../build/tmp/deploy/images/$1)
else
    YOCTO_DIR=(${SCRIPT_DIR}/../../../build/tmp/deploy/images/*)
fi

if [ ! -e "${YOCTO_DIR}" ]; then
    echo "Error: path does not exist: ${YOCTO_DIR}"
    exit 1
fi

if [ -z "$1" ] && [ "${#YOCTO_DIR[@]}" -ne 1 ]; then
    echo "Error: Found ${#YOCTO_DIR[@]} image directories under 'tmp/deploy/images/'"
    for dir in "${YOCTO_DIR[@]}"; do
        dir="${dir%/}"
        echo "  $(basename "$dir")"
    done
    echo "Run this script with one of the machines listed above."
    exit 1
fi

SYNAIMG=$(find ${YOCTO_DIR} -maxdepth 1 -name "SYNAIMG" -type d | head -n 1)
KERNEL=$(find ${YOCTO_DIR} -maxdepth 1 -name "Image" -type l | head -n 1)
DTB=$(find ${YOCTO_DIR} -maxdepth 1 -name "*.dtb" -type l | head -n 1)
ROOTFS=$(find ${YOCTO_DIR} -maxdepth 1 -name "*rootfs.tar.xz" -type l | head -n 1)

if [ -z "${SYNAIMG}" ] || [ ! -d "${SYNAIMG}" ]; then
    echo "Error: SYNAIMG not found"
    exit 1
fi

if [ -z "$KERNEL" ]; then
    echo "Error: KERNEL not found"
    exit 1
fi

if [ -z "$DTB" ]; then
    echo "Error: DTB not found"
    exit 1
fi

if [ -z "$ROOTFS" ]; then
    echo "Error: ROOTFS not found"
    exit 1
fi

set -eu
echo "Using from env:"
echo "  TFTP_PATH=$TFTP_PATH"
echo "  TFTP_KERNEL_BIN_PATH=$TFTP_KERNEL_BIN_PATH"
echo "  TFTP_DTB_BIN_PATH=$TFTP_DTB_BIN_PATH"
echo "  TFTP_IMAGE_PATH=$TFTP_IMAGE_PATH"
echo "  NFS_ROOTFS_PATH=$NFS_ROOTFS_PATH"

set +eu
sudo cp -f "${KERNEL}" "${TFTP_PATH}/${TFTP_KERNEL_BIN_PATH}"
sudo cp -f "${DTB}" "${TFTP_PATH}/${TFTP_DTB_BIN_PATH}"
sudo rsync -a ${SYNAIMG}/ "${TFTP_PATH}/${TFTP_IMAGE_PATH}"
echo "Copying rootfs to ${NFS_ROOTFS_PATH}.."

if [ ! -d "${NFS_ROOTFS_PATH}" ]; then
    echo "Error: Path: ${NFS_ROOTFS_PATH} not valid! Source setup.sh first!"
    exit 1
fi

sudo find "${NFS_ROOTFS_PATH}" -mindepth 1 -delete
sudo tar -xpf ${ROOTFS} -C ${NFS_ROOTFS_PATH}
