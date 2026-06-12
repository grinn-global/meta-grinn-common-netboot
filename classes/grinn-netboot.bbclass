grinn_validate_netboot_env() {
    if [ -z ${NETBOOT_SERVER_IP} ]; then
        bbfatal "NETBOOT_SERVER_IP cannot be empty"
    fi

    if [ -z ${NETBOOT_SERVER_SUBDIR} ]; then
        bbfatal "NETBOOT_SERVER_SUBDIR cannot be empty"
    fi
}
