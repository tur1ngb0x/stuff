#!/usr/bin/env bash

if [[ -f /usr/bin/pacman ]]; then
	sudo pacman -S --noconfirm --needed mariadb
	sudo pacman -S --noconfirm --needed mysql-workbench gnome-keyring
	sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	sudo systemctl enable --now mariadb.service
	echo "Type 'sudo mysql_secure_installation' to begin mysql setup"
elif [[ -f /usr/bin/apt ]]; then
	if [[ $(uname -a | grep -i 'microsoft-standard-wsl2') ]]; then
		sudo apt install -y mysql-server
		sudo /etc/init.d/mysql start
		echo "Type 'sudo mysql_secure_installation' to begin mysql setup"
	else
		sudo apt install -y gnupg wget
		wget -O /tmp/mysql-apt-config.deb https://repo.mysql.com/mysql-apt-config_0.8.17-1_all.deb
		sudo apt install /tmp/mysql-apt-config.deb
		sudo apt update && sudo apt install -y mysql-server
		sudo apt install -y mysql-workbench-community gnome-keyring
	fi
elif [[ -f /usr/bin/dnf ]]; then
	sudo dnf install http://repo.mysql.com/mysql80-community-release-fc34-1.noarch.rpm
	sudo dnf update && sudo dnf install -y mysql-community-server
	sudo dnf install -y mysql-workbench-community gnome-keyring
	sudo systemctl enable --now mysql.service
	sudo grep -i "temporary password" "/var/log/mysqld.log"
	echo "Type 'sudo mysql_secure_installation' to begin mysql setup"
fi

cat << EOF

LOGIN AS ROOT USER:
$ mysql -u root -p

CREATE A NEW USER:
mysql> CREATE USER 'john'@'localhost' IDENTIFIED BY '1234';
mysql> GRANT ALL PRIVILEGES ON *.* TO 'john'@'localhost';
mysql> FLUSH PRIVILEGES;
mysql> EXIT;

LOGIN AS NEW USER:
$ mysql -u john -p 1234

EOF
