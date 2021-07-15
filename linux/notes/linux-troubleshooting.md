# Upload logs
`command | curl -F 'f:1=<-' ix.io`

`command | nc termbin.com 9999`

# System
### Check distributon info
`cat /etc/os-release`

### Check system logs 
`journalctl -p3 -xb`

### Check service logs
`journalctl -xb -u <unit_name>`

### Check system status
`uptime`

### Check system resources
`top`

### Kill system process
`kill -9 <process_id>`

`killall -9 <process_id>`

# Kernel
### Check kernel information
`uname -a`

### Check module information
`modinfo <module-name>`

### Check if a module is loaded in the kernel
`lsmod | grep -i <module-name>`

### Load a module into the kernel
`sudo modprobe <module-name>`

### Load a module into the kernel with different name
`sudo modprobe <module-name> -o <module-name-new>`

### Remove module from the kernel
`sudo modprobe -r <module-name>`

# Memory
### Check memory info
`free -mltw`

`watch -c -n1 free -mltw`

`sudo dmidecode -t17`

# Disk
### Check disk info and partitions
`sudo parted -l`

`df -h`

`lsblk -f`

### Check disk health
`sudo smartctl -a /dev/sda`

### Repair disk
`sudo fsck -ACV /dev/sda`

### Change ownership to current user of a disk/partition/folder
`sudo chown -R $USER:$USER /path/to/take/ownership`

# Device
### Check device info
`lspci -nnk`

`lsusb`

`lsusb -vt`

# Display
### Check Xserver logs
Xorg : `/var/log/Xorg.0.log`

Xorg User : `~/.local/share/xorg/Xorg.log`

# Network
### Check network info
`ifconfig`

`iwconfig`

`ping -c5 google.com`

`traceroute google.com`
