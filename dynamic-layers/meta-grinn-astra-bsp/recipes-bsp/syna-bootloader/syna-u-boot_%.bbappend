inherit grinn-netboot

NETBOOT_SOC_BOOTARGS:dolphin = "avio.fastlogo_status=25025 syna_drm.logo_info=c3f91000@780x438-f00 cma=524288000@3166699520"
NETBOOT_SOC_BOOTARGS:klamath = ""

SYNAPTICS_SOC_CODENAME:grinn-astra-1680-som = "dolphin"
SYNAPTICS_SOC_CODENAME:grinn-astra-261x-som = "klamath"

do_configure:prepend:grinn-astra-som() {
    grinn_validate_netboot_env

    cat > ${WORKDIR}/${SYNAPTICS_SOC_CODENAME}.env <<EOF
netboot=1
netboot_server_ip=${NETBOOT_SERVER_IP}
netboot_server_subdir=${NETBOOT_SERVER_SUBDIR}
kernel_addr_r=0x7c00000
fdt_addr_r=0x47f1000
set_enable_overrides=env set skip_fdt_update 0
set_disable_overrides=env set skip_fdt_update 2

netboot_set_bootargs=setenv bootargs console=ttyS0,115200 root=/dev/nfs rw nfsroot=\${netboot_server_ip}:/\${netboot_server_subdir},vers=4,proto=tcp ip=dhcp rootwait ${NETBOOT_SOC_BOOTARGS}
netboot_setup_net=net_init; dhcp; setenv serverip \${netboot_server_ip}
netboot_load_kernel=tftpboot \${kernel_addr_r} \${netboot_server_subdir}/Image
netboot_load_fdt=tftpboot \${fdt_addr_r} \${netboot_server_subdir}/${MACHINE}.dtb
netboot_exec=booti \${kernel_addr_r} - \${fdt_addr_r}

netboot_run=run set_disable_overrides; run netboot_setup_net; run netboot_set_bootargs; run netboot_load_kernel; run netboot_load_fdt; run netboot_exec
mmc_run=run set_enable_overrides; env delete bootargs; bootmmc

bootcmd=if test \${netboot} = 1; then run netboot_run; else run mmc_run; fi

tftp_flash=run netboot_setup_net; tftp2emmc \${netboot_server_subdir}/SYNAIMG
EOF

    install -D -m 0644 ${WORKDIR}/${SYNAPTICS_SOC_CODENAME}.env \
        ${S}/board/synaptics/${SYNAPTICS_SOC_CODENAME}/${SYNAPTICS_SOC_CODENAME}.env
}
