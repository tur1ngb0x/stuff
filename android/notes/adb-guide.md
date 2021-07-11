# Install ADB on your PC
* **Windows**
	* Install Chocolatey : https://chocolatey.org/docs/installation
	* Open Command Prompt as Admin : `choco install adb`

* **Linux**
	* APT : `sudo apt install android-sdk-platform-tools`
	* PACMAN : `sudo pacman -Syu android-tools`
	* DNF : `sudo dnf install android-tools`

* **MacOS**
    * Install Homebrew : https://brew.sh
	* `brew install android-platform-tools`

# ADB Commands
Go to your phone Settings App > Developer Options > USB Debugging > Enable

You should get a prompt on your Android phone(s), allow the needed permission.

**NOTE** : If the device does not get detected on Windows 10 using `adb devices` or `fastboot devices`, go to Settings App > Update & Security > View optional updates > Driver Updates > Android Device > Install > Unplug > Replug the phone

* **List connected devices**

    `adb devices -l`

* **Reboot phone**

    `adb reboot`

* **Reboot phone to recovery mode**

    `adb reboot recovery`

* **Reboot phone to bootloader mode**

    `adb reboot-bootloader`

* **Transfer file/folder from phone to PC**

    If `<destination_pc>` is not mentioned, it will copy data to current working folder on PC

    `adb pull <source_phone> <destination_pc>`

    `adb pull <source_phone>`

* **Transfer file/folder from PC to phone**

    `adb push <source_pc> <destination_phone>`

* **List all system apps**

    `adb shell "pm list package -s"`

* **List all system apps including un-installed ones**

    `adb shell "pm list package -s -u"`

* **List all user installed apps**

    `adb shell "pm list packages -3"`

* **Uninstall system app**

    `adb shell "pm uninstall --user 0 -k <package_name>"`

* **List all system uninstalled apps**

    `adb shell "(pm list packages -u && pm list packages) | sort | uniq -u"`

* **Re-install system app**

    `adb shell "cmd package install-existing <package_name>"`

* **Re-install all uninstalled system apps on a Linux Machine**

    `for i in $(adb shell "(pm list packages -u && pm list packages) | sort | uniq -u | cut -c 9-") ; do adb shell cmd package install-existing "$i" ; done`

* **Disable system app**

    `adb shell "pm disable-user --user 0 <package_name>"`

* **List all system disabled apps**

    `adb shell "pm list packages -d"`

* **Re-enable system app**

    `adb shell "pm enable --user 0 <package_name>"`

* **Re-enable all disabled system apps on a Linux Machine**

    `for i in $(adb shell "(pm list packages -d | sort | cut -c 9-)") ; do adb shell pm enable --user 0 "$i" ; done`

* **Freeze app**

    `adb shell "cmd appops set <package_name> RUN_IN_BACKGROUND ignore"`

* **Unfreeze app**

    `adb shell "cmd appops set <package_name> RUN_IN_BACKGROUND allow"`

* **Reset app permissions**

    `adb shell "pm reset-permissions -p <package_name>"`

* **Install app**

    `adb shell "<source_phone>"`

    `adb shell "<source_pc>"`

* **Change screen DPI**

    `adb shell "wm density <value>"`

* **Reset screen DPI**

    `adb shell "wm density reset"`

* **Change screen resolution**

    `adb shell "wm size <height>x<width>"`

* **Reset screen resolution**

    `adb shell "wm size reset"`

* **Get Android version**

    `adb shell "getprop ro.build.version.release"`

* **Backing up Downloads folders on phone to PC**

    `adb pull /sdcard/ADM`

    `adb pull /sdcard/Download`

    `adb pull /sdcard/Downloads`

    `adb pull /sdcard/IDM`

    `adb pull /sdcard/IDMP`

* **Backing up Media folders on phone to PC**

    `adb pull /sdcard/DCIM/Camera`

    `adb pull /sdcard/DCIM/Screenshots`

    `adb pull /sdcard/Documents`

    `adb pull /sdcard/Movies`

    `adb pull /sdcard/Music`

    `adb pull /sdcard/Pictures`

    `adb pull /sdcard/Ringtones`

    `adb pull /sdcard/Videos`

* **Backing up Messaging folders on phone to PC**

    `adb pull /sdcard/Hike`

    `adb pull /sdcard/Plus`

    `adb pull /sdcard/Telegram`

    `adb pull /sdcard/WhatsApp`

* **Delete files in a phone directory older than 180 days**

    `adb shell "find /path/to/folder -mtime +180 -exec rm {} \;"`

* **Tags**

    `source_phone` : Path to file/folder on phone

    `source_pc` : Path to file/folder on PC

    `destination_phone` : Path to file/folder on phone

    `destination_pc` : Path to file/folder on PC

    `package_name` : package name of the application

    `value` : number range from 200-600

    `height` : number in vertical pixels

    `width` : number in horizontal pixels

* **Android Phone Paths**

    `/system` : System data + System apps

    `/data` : User data + User apps + Internal Storage

    `/sdcard` : Internal storage

    `/sdcard/DCIM` : DCIM folder in internal storage

    `/sdcard/Downloads` : Downloads folder in internal storage

    `/sdcard/Pictures` : Pictures folder in internal storage

    `/sdcard1` : External storage (micro sdcard)

    `/sdcard2` : External storage (micro sdcard + otg connection)

* **Windows Paths (replace username with your actual username)**

    `C:\Users\username` : Home

    `C:\Users\username\Desktop` : Desktop

    `C:\Users\username\Downloads` : Downloads

    `$HOME` : HOME (powershell only)

    `$HOME\Desktop` : HOME (powershell only)

    `$HOME\Downloads` : HOME (powershell only)

    `C:\` : C Drive

    `D:\` : D Drive

    `E:\` : E Drive

* **Linux Paths (replace username with your actual username)**

    `/` : Root

    `/home/username` : Home

    `~` : Home

    `$HOME` : Home

    `~/Desktop` : Desktop

    `~/Downloads` : Downloads

* **Misc**

    To remove "package:" from STDOUT

    `command | cut -c 9-`

    Convert STDOUT column into array

    `command | xargs`
