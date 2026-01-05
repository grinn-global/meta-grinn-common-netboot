UBOOT_DIR = "${S}/boot/u-boot"
require net_commands.inc

PREBOOT="\
${PREBOOT_ENV};\
${SRV_IP_ENV};\
${TFTP_IMAGE_ENV};\
${TFTP_KERNEL_ENV};\
${TFTP_DTB_ENV};\
${TFTP_FLASH_ENV};\
${NFS_ENV};\
${BOOTARGS_ENV};\
${NETBOOT_ENV};\
${NETBOOT_BOOT_ENV};\
"

do_configure:prepend() {
    NETBOOT_SERVER_IP="${NETBOOT_SERVER_IP}"
    NFS_ROOTFS_PATH="${NFS_ROOTFS_PATH}"
    TFTP_KERNEL_BIN_PATH="${TFTP_KERNEL_BIN_PATH}"
    TFTP_DTB_BIN_PATH="${TFTP_DTB_BIN_PATH}"
    TFTP_IMAGE_PATH="${TFTP_IMAGE_PATH}"

    for var in NETBOOT_SERVER_IP NFS_ROOTFS_PATH TFTP_KERNEL_BIN_PATH TFTP_DTB_BIN_PATH TFTP_IMAGE_PATH; do
        eval value=\$$var
        if [ -z "$value" ]; then
            bbfatal "Net boot variable: $var is not set: $value"
        fi
    done

    # Append variables from Yocto into the u-boot config fragment
    cat > ${WORKDIR}/net_conf.cfg <<'EOF'
CONFIG_BOOTCOMMAND="${BOOTCOMMAND}"
CONFIG_USE_PREBOOT=y
CONFIG_PREBOOT="${PREBOOT}"
EOF
}

do_compile:prepend() {
    # merge current dolphin config file with provided fragment
    ${UBOOT_DIR}/scripts/kconfig/merge_config.sh -m -O ${WORKDIR} \
        ${UBOOT_DIR}/configs/dolphin_suboot_defconfig \
        ${WORKDIR}/net_conf.cfg

    # use merged config file
    cp ${WORKDIR}/.config ${UBOOT_DIR}/configs/dolphin_suboot_defconfig
}
