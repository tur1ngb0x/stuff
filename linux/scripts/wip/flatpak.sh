# install flatpak
sudo bash -c 'apt-get install -y flatpak || dnf install -y flatpak || pacman -S --needed --noconfirm flatpak'

# list remotes
flatpak remotes --columns=name,options,url

# delete all remotes
for scope in --user --system; do
    flatpak remotes "${scope}" --show-disabled --columns=name | while IFS= read -r remote; do
        echo " + [[ -n ${remote} ]] && flatpak remote-delete ${scope} ${remote}"
        [[ -n "${remote}" ]] && flatpak remote-delete "${scope}" "${remote}"
    done
done

# setup flathub
flatpak --user remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# list remotes
flatpak remotes --columns=name,options,url
