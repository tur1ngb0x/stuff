#!/usr/bin/env bash

# apt
sudo apt-get install --reinstall -y software-properties-common
sudo add-apt-repository -yn ppa:git-core/ppa
sudo apt update
sudo apt-get install --reinstall git 

# dnf
sudo dnf install --assumeyes git git-credential-libsecret

# pacman
sudo pacman -Syu --needed --noconfirm git

# credential helper = oauth
wget -4 -O '/tmp/git-credential-oauth.tar.gz' 'https://github.com/hickford/git-credential-oauth/releases/download/v0.16.0/git-credential-oauth_0.16.0_linux_amd64.tar.gz'
tar -f '/tmp/git-credential-oauth.tar.gz' -xzv -C /tmp
sudo install -v -D -o root -g root -m 0755 /tmp/git-credential-oauth /usr/local/bin/git-credential-oauth

# ssh
gen_key_pair() {
    if [[ $# -ne 2 ]]; then
        printf "usage: generate_key <remote> <user>\n"
        return
    fi

	local name_remote="${1}"
    local name_user="${2}"

    local key_base="rsa4096-${name_remote}-${name_user}"
    local key_private="${HOME}/.ssh/${key_base}"
    local key_public="${key_private}.pub"

    mkdir -p "${HOME}/.ssh" && chmod 700 "${HOME}/.ssh" || return

    if [ -e "${key_private}" ]; then
        printf "key exists: %s\n" "${key_private}" >&2
        return
    fi

    printf "remote: %s\nuser: %s\nprivate: %s\npublic: %s\n" "${name_remote}" "${name_user}" "${key_private}" "${key_public}"

    ssh-keygen -vvv -t rsa -b 4096 -f "${key_private}" -C "${key_base}" || return 5

    if [ -z "${SSH_AUTH_SOCK}" ] || [ ! -S "${SSH_AUTH_SOCK}" ]; then
        eval "$(ssh-agent -s)" > /dev/null
    fi

    ssh-add -vvv "${key_private}" > /dev/null 2>&1

    cat "${key_public}"
}

# common
# key_ssh $REMOTE $USER
generate_key 'github' 'tur1ngb0x'
generate_key 'gitlab' 'tur1ngb0x'
