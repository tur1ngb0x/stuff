[[ "$(id -u)" -eq 0 ]] || { echo "ERROR: must run as root" >&2; exit 1; }

dpkg-query -W -f='${Package}\t${Version}\n' | LC_ALL=C sort | tee /home/dpkg-name-version.txt

dpkg-query -W -f='${Package}\n' | LC_ALL=C sort | tee /home/dpkg-name.txt

rpm -qa --qf '%{NAME}\t%{VERSION}\n' | LC_ALL=C sort | tee /home/rpm-name-version.txt

rpm -qa --qf '%{NAME}\n' | LC_ALL=C sort | tee /home/rpm-name.txt

pacman -Qen | awk '{ print $1 "\t" $2 }' | LC_ALL=C sort | tee /home/pacman-name-version.txt

pacman -Qen | awk '{ print $1 }' | LC_ALL=C sort | tee /home/pacman-name.txt
