GRINN_NETBOOT_DEPLOY_DIR ?= "${DEPLOY_DIR_IMAGE}/netboot"
GRINN_NETBOOT_TFTP_ARTIFACTS ??= ""
GRINN_NETBOOT_NFS_ARTIFACTS ??= ""

grinn_netboot_link_artifacts() {
    local target_dir=$1
    shift

    for artifact in "$@"; do
        # Use hard links to save disk space
        cp -rlL "${DEPLOY_DIR_IMAGE}/${artifact}" "${target_dir}/" \
            || bbfatal "Missing netboot artifact: ${DEPLOY_DIR_IMAGE}/${artifact}"
    done
}

do_grinn_netboot_image_deploy() {
    [ -n "${GRINN_NETBOOT_TFTP_ARTIFACTS}" ] || bbfatal "GRINN_NETBOOT_TFTP_ARTIFACTS is not defined"
    [ -n "${GRINN_NETBOOT_NFS_ARTIFACTS}" ] || bbfatal "GRINN_NETBOOT_NFS_ARTIFACTS is not defined"

    rm -rf "${GRINN_NETBOOT_DEPLOY_DIR}"
    install -d "${GRINN_NETBOOT_DEPLOY_DIR}/tftp" "${GRINN_NETBOOT_DEPLOY_DIR}/nfs"

    grinn_netboot_link_artifacts "${GRINN_NETBOOT_DEPLOY_DIR}/tftp" ${GRINN_NETBOOT_TFTP_ARTIFACTS}
    grinn_netboot_link_artifacts "${GRINN_NETBOOT_DEPLOY_DIR}/nfs" ${GRINN_NETBOOT_NFS_ARTIFACTS}
}

addtask grinn_netboot_image_deploy after do_image_complete before do_build
