#!/bin/sh

# ----------------------------
# Configuration
# ----------------------------
base_dir="${HOME}/src"
vm_dir="${base_dir}/vbox"
data_dir="${base_dir}/data"

# ----------------------------
# Helpers
# ----------------------------
banner()
{
    tput rev 2>/dev/null
    printf '%s\n' " [*] ${1} "
    tput sgr0 2>/dev/null
}

usage()
{
    cat <<EOF
Usage:
  vbox.sh check                              perform system checks
  vbox.sh list                               list all virtual machines
  vbox.sh create <vm_name> <iso_path>        create a virtual machine
  vbox.sh run <vm_name|vm_uuid>              start a virtual machine
  vbox.sh delete <vm_name|vm_uuid>           delete a virtual machine
  vbox.sh restore <vm_name|vm_uuid> <snap>   restore a virtual machine snapshot
  vbox.sh snapshot                           list snapshots for all vms
  vbox.sh snapshot <vm_name|vm_uuid>         list snapshots for a vm
  vbox.sh snapshot <vm_name|vm_uuid> <text>  take a snapshot
EOF
    exit 1
}



confirm_user()
{
    action="${1:?}"

    printf '%s' "Confirm ${action}? Type 'yes' to continue: "
    read answer

    if [ "${answer}" != "yes" ]; then
        printf '%s\n' "Aborted."
        exit 0
    fi
}

list_vms()
{
    banner "vm (registered)"
    vboxmanage list vms --sorted
    banner "vm (running)"
    vboxmanage list runningvms --sorted
}

# ----------------------------
# Diagnostics
# ----------------------------
check_vm()
{
    failed=0

    banner "checking if vboxmanage exists"
    if command -v vboxmanage >/dev/null 2>&1; then
        printf '%s\n' "OK"
    else
        printf '%s\n' "ERROR: vboxmanage not found in PATH" >&2
        failed=1
    fi

    banner "checking if directories exist"
    for d in "${base_dir}" "${vm_dir}" "${data_dir}"; do
        if [ -d "${d}" ] && [ -w "${d}" ]; then
            printf '%s\n' "OK: ${d}"
        else
            printf '%s\n' "ERROR: directory missing or not writable: ${d}" >&2
            failed=1
        fi
    done

    banner "checking if kvm modules are unloaded"
    if lsmod 2>/dev/null | grep -q '^kvm'; then
        printf '%s\n' "ERROR: kvm modules are loaded and may conflict with virtualbox" >&2
        failed=1
    else
        printf '%s\n' "OK"
    fi

    banner "checking if user is a part of vboxusers group"
    if id -G -n | grep -qw vboxusers; then
        printf '%s\n' "OK"
    else
        printf '%s\n' "ERROR: user is not in vboxusers group" >&2
        failed=1
    fi

    if [ "${failed}" -eq 0 ]; then
        exit 1
    fi
}

# ----------------------------
# Actions
# ----------------------------
create_vm()
{
    vm_name="${1:?}"
    iso_path="${2:?}"

    confirm_user "create VM '${vm_name}'"

    vm_path="${vm_dir}/${vm_name}"
    disk_path="${vm_path}/${vm_name}.vdi"

    if vboxmanage showvminfo "${vm_name}" >/dev/null 2>&1; then
        printf '%s\n' "ERROR: VM '${vm_name}' already exists" >&2
        exit 1
    fi

    if [ ! -r "${iso_path}" ]; then
        printf '%s\n' "ERROR: ISO not found or not readable: ${iso_path}" >&2
        exit 1
    fi

    mkdir -p "${vm_path}" "${data_dir}"

    banner "creating vm"

    vboxmanage createvm --name "${vm_name}" --ostype Linux_64 --register --basefolder "${vm_dir}"

    vboxmanage modifyvm "${vm_name}" --firmware bios --boot1 disk --boot2 dvd --boot3 none --boot4 none
    vboxmanage modifyvm "${vm_name}" --cpus 4 --x86-pae on --nested-hw-virt on --nested-paging on
    vboxmanage modifyvm "${vm_name}" --memory 4096 --vram 128 --graphicscontroller vmsvga
    vboxmanage modifyvm "${vm_name}" --drag-and-drop bidirectional --clipboard-mode bidirectional --clipboard-file-transfers enabled
    vboxmanage modifyvm "${vm_name}" --nic1 nat
    vboxmanage modifyvm "${vm_name}" --natpf1 "guest_ssh,tcp,127.0.0.1,2222,,22"

    vboxmanage storagectl "${vm_name}" --name "SATA Controller" --add sata --controller IntelAhci
    vboxmanage storagectl "${vm_name}" --name "IDE Controller" --add ide

    vboxmanage createmedium disk --filename "${disk_path}" --size 20480

    vboxmanage storageattach "${vm_name}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${disk_path}"
    vboxmanage storageattach "${vm_name}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${iso_path}"

    vboxmanage sharedfolder add "${vm_name}" --name vbox_data --hostpath "${data_dir}" --automount
    vboxmanage modifyvm "${vm_name}" --snapshotfolder "${vm_path}"

    vboxmanage snapshot "${vm_name}" take "$(date +%Y%m%d%H%M%S)-blankdisc"
}

run_vm()
{
    vm_name="${1:?}"

    confirm_user "start VM '${vm_name}'"

    banner "starting vm"
    vboxmanage startvm "${vm_name}"
}

delete_vm()
{
    vm_name="${1:?}"

    confirm_user "delete VM '${vm_name}'"

    banner "deleting vm"
    vboxmanage unregistervm "${vm_name}" --delete
}

restore_vm()
{
    vm_name="${1:?}"
    snapshot_name="${2:?}"

    confirm_user "restore VM '${vm_name}' to snapshot '${snapshot_name}'"

    banner "restoring vm snapshot"
    vboxmanage snapshot "${vm_name}" restore "${snapshot_name}"
}

snapshot_vm()
{
    if [ "${#}" -eq 0 ]; then
        banner "snapshots (all vms)"
        for vm in $(vboxmanage list vms | awk -F\" '{print $2}'); do
            printf '%s\n' "VM: ${vm}"
            vboxmanage snapshot "${vm}" list 2>/dev/null || true
        done
        return 0
    fi

    vm_name="${1}"
    shift

    if [ "${#}" -eq 0 ]; then
        banner "snapshots for vm '${vm_name}'"
        vboxmanage snapshot "${vm_name}" list
        return 0
    fi

    snapshot_name="${*}"

    confirm_user "take snapshot '${snapshot_name}' for VM '${vm_name}'"

    banner "taking vm snapshot"
    vboxmanage snapshot "${vm_name}" take "${snapshot_name}"
}



# ----------------------------
# Main
# ----------------------------
main()
{
    [ "${#}" -ge 1 ] || usage

    cmd="${1}"
    shift

    case "${cmd}" in
        list)     [ "${#}" -eq 0 ] && list_vms        || usage ;;
        create)   [ "${#}" -eq 2 ] && create_vm "${@}" || usage ;;
        run)      [ "${#}" -eq 1 ] && run_vm "${1}"    || usage ;;
        delete)   [ "${#}" -eq 1 ] && delete_vm "${@}" || usage ;;
        restore)  [ "${#}" -eq 2 ] && restore_vm "${@}"|| usage ;;
        snapshot) snapshot_vm "${@}" ;;
        check)    [ "${#}" -eq 0 ] && check_vm         || usage ;;
        -h|--help) usage ;;
        *)        usage ;;
    esac
}



main "${@}"
