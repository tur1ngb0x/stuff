# Tips for Dual Booting on separate disks with UEFI

### BEFORE INSTALLATION
1. Backup data
	1. Backup all data present on the computer to an external media.
	2. Anything can go wrong during the dual booting process, having backup of data is invaluable.
2. UEFI updates
	1. Apply UEFI updates for the desktop/laptop if available from manufacturer's website.
	2. Some OEMs add Linux hardware support on computers via UEFI updates.
	3. WARNING: If you flash incorrect UEFI file or if the computer switches off during UEFI flashing, your computer can get bricked.
4. Windows settings
	1. Open "Command Prompt" as administrator.
	2. Inside Command Prompt, type `powercfg -h off`, press Enter.
	3. This disables "Fast Startup" on Windows feature which causes lots of issues on Linux.
	4. Reboot the computer.
5. UEFI settings (some options might not be available)
	- Secure Boot : Disabled
	- Boot Mode : UEFI
	- CSM Support : Disabled
	- Fast Boot : Disabled
	- RAID 0 / RAID 1 : Disabled
	- Intel RST : Disabled
	- Storage Controller Mode : AHCI
	- Touchpad : Advanced
	- USB Boot : Enabled
	- Disable the Windows disk from UEFI settings or unplug the Windows disk.

### DURING INSTALLATION
1. SATA HDDs/SSDs will show up as `/dev/sd*`, where `*` is the alphabet and number for each SATA disk and its partition(s) respectively.
2. NVME SSDs will show up as `/dev/nvme*`, where `*` is the alphabet and number for each NVME disk and its partition(s) respectively.
3. Ensure that the Windows disk does not show up. You can verify that using:
	1. Linux Graphical Installer Menu
	2. Terminal Commands
		- `parted -l`
		- `lsblk -f` 
4. Select the non-Windows disk for installing Linux.

### AFTER INSTALLATION
1. Boot into Linux using UEFI boot menu.
	1. For `grub` boot loader
		1. Inside Linux, open `/etc/default/grub` as the root user using a text editor.
		2. Add `GRUB_DISABLE_OS_PROBER=true` at the end and save the file.
		3. Re-generate the GRUB configuration by referring your Linux distribution's wiki or manual.
	2. For `systemd-boot` boot manager, no configuration is required.
	3. For `refind` boot manager, no configuration is required.
	4. Inside Linux, configure the clock so that it does not conflict with Windows clock settings.
		- `sudo timedatectl set-timezone Asia/Kolkata`
		- `sudo ln -sv /usr/share/zoneinfo/Asia/Kolkata /etc/localtime`
		- `sudo timedatectl set-local-rtc 1 --adjust-system-clock`
2. Enable the Windows disk from UEFI settings or re-plug the disk.
3. Boot into Windows using UEFI boot menu.
	- Open Disk Management, right click Linux disk and mark it "Offline".
	- Open time settings and sync the clock.

### DISK LAYOUT AFTER DUAL BOOTING
- Disk 0 : Windows `[EFI] [MSR] [C] [RECOVERY]`
- Disk 1 : Linux `[EFI] [SWAP] [ROOT] [HOME]`

### UEFI BOOT MENU AFTER DUAL BOOTING
- Entry 1 : `Windows Boot Manager (Disk 0 Name)`
- Entry 2 : `Linux Distribution Name (Disk 1 Name)`
