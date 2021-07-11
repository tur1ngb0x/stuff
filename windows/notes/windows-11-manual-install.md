# Install Windows 11 manually on older hardware

Credits:
* Source : ChrisTitusTech on YouTube
* Video : https://www.youtube.com/watch?v=wK40EFgzmqM

```
windows installer iso   = letter C
windows efi partition   = letter G
windows os partition    = letter D
```

* Boot into Windows 11 Installer via USB
* Open Command Prompt using `[Shift Key] + [F10 Key]`
* `diskpart`
    * `list disk`
    * Select your disk by the number, replace X by the number
    * `select disk X`
    * All data will be wiped
    * `clean`
    * `convert gpt`
    * Create EFI partition
    * `create partition efi size=512`
    * `format fs=fat32 quick`
    * `assign letter=G`
    * Create OS partition
    * `create partition primary`
    * `format fs=ntfs quick`
    * `assign letter=D`
    * `exit`
* Change directory to D (OS) partition
    * `D:`
* Get the indices of Windows editions on the bootable iso
    * `DISM /Get-ImageInfo /imagefile:C:\sources\install.wim`
* Select the index for the Windows edition you want to install.
* Indices can change depending on the ISO, your ISO can have indices starting from 1 to 15, example:
    ```
    Index : 1
    Name : Windows 11 Pro
    Description : Windows 11 Pro
    Size: 16,161,119,665 bytes
    ```
* Install Windows 11 on D (OS) partition using the index
    * `DISM /apply-image /imagefile:C:\sources\install.wim /index:1 /applydir:D:\`
* Create a bootable EFI (G) partition
    * `bcdboot D:\Windows /s G: /f ALL`
* Close the installer window, unplug the USB.
* Reboot the system.

