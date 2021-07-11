# Linux Ubiquity Installer Disk Partitioning

Notes:
* To install Linux, you need to create a minimum of :
    * 2 partitions on a UEFI/GPT scheme.
        * ESP (EFI System Partition)
        * Root (/).
    * 1 partition on a BIOS/MBR scheme
        * Root (`/`)
* All other partitions are optional as per user preference.
* If the user does not manually create a "Swap Partition" during installation, Linux Ubiquity Installer will automatically create "Swap File" (`/swapfile`) of 2GB in size inside Root (`/`) partition.
* For advanced users only, tweaks these values to configure swap usage:
    * `vm.swappiness`
        * Default is 60, Range is 0 to 100
        * Higher value increases swap usage
    * `vm.vfs_cache_pressure`
        * Default is 100, Range is 0 to 200

### 1. UEFI/GPT Scheme
1. Partition #1 : EFI (Compulsory)
    1. Usage : For the bootloader
    2. Size :
        * Minimum Size : 300MB
        * Recommended Size : 512MB
    3. Type : Primary
    4. Location : Beginning
    5. Use As : EFI System Partition
2. Partition #2 : Root (Compulsory)
    1. Usage : For the operating system
    2. Size :
        * Minimum Size : 50GB
        * Maximum Size : Remaining disk space
    3. Type : Primary
    4. Location : Beginning
    5. Use As : ext4/btrfs
    6. Mount Point : `/`
3. Partition #3 : Swap (Optional)
    1. Usage : For temporary data
    2. Size :
        * Minimum Size : 2GB
        * Recommended Size
        * Maximum Size : Equal to RAM size

        * Equal to RAM size if using hibernate feature.
        * Less than RAM size if not using hibernate feature.
    3. Type : Primary
    4. Location : Beginning
    5. Use As : swaparea
4. Partition #4 : Home (Optional)
    1. Usage : For user config, files and data
    2. Size : Remaining Space
    3. Type : Primary
    4. Location : Beginning
    5. Use As : ext4/btrfs
    6. Mount Point : /home
5. Partition #5 : Data (Optional)
    1. Usage : For storing large files
    2. Size : Remaining Space
    3. Type : Primary
    4. Location : Beginning
    5. Use As : ext4/btrfs/exfat/ntfs
    6. Mount Point : /mnt/data

