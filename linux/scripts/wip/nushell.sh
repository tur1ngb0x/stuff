api="https://api.github.com/repos/nushell/nushell/releases/latest"
source="https://github.com/nushell/nushell/releases/latest"
tag="$(curl -fsSL "${api}" | jq -r ".tag_name")"

target="/usr/local/bin"
file="nu-${tag}-x86_64-unknown-linux-gnu.tar.gz"
url="https://github.com/nushell/nushell/releases/download/${tag}/${file}"

{
    printf "source: %s\n" "${source}"
    printf "url: %s\n" "${url}"
    printf "target: %s\n" "${target}"
} | column -t
printf "download & install? (N/y) "

read -r reply
[[ "${reply}" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }

sudo mkdir -p "${target}"
sudo curl -fL "${url}" | sudo tar -v -xzf - -C "${target}" --strip-components=1

find "${target}" -mindepth 1 -iname '*nu*' | sort