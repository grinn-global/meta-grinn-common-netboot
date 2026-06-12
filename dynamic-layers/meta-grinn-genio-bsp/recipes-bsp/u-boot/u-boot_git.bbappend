inherit grinn-netboot

SRC_URI:append = " file://boot.script;subdir=orig"

do_configure:append:grinn-genio-som() {
    grinn_validate_netboot_env

    cat > ${WORKDIR}/netboot.script <<EOF
env exists netboot || setenv netboot 1
if test "\${netboot}" -eq 1; then
    env exists netboot_server_ip || setenv netboot_server_ip ${NETBOOT_SERVER_IP}
    env exists netboot_server_subdir || setenv netboot_server_subdir ${NETBOOT_SERVER_SUBDIR}
    env exists bootargs || setenv bootargs "console=ttyS0,921600 root=/dev/nfs rw nfsroot=\${netboot_server_ip}:\${netboot_server_subdir}/,vers=4,proto=tcp ip=dhcp rootwait"
    setenv autoload no
    dhcp
    setenv serverip \${netboot_server_ip}
    setenv kerneladdr 0x4A000000
    env exists boot_conf || setenv boot_conf "\${fdt_boot_conf}"
    tftpboot \${kerneladdr} \${netboot_server_subdir}/fitImage
    bootm \${kerneladdr}\${boot_conf}
fi
EOF

    cat ${WORKDIR}/netboot.script ${WORKDIR}/orig/boot.script > ${WORKDIR}/boot.script
}
