pkgs_pacman=(
    7zip
    alacritty
    android-tools
    atool
    base-devel
    bash-completion
    bat
    chromium
    cmake
    curl
    curl
    dialog
    docker
    dos2unix
    duf
    dust
    eza
    fd
    ffmpeg
    firefox
    flatpak
    fzf
    git
    lazygit
    lm_sensors
    man-db
    mediainfo
    micro
    most
    nano
    ncdu
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    pacman-contrib
    pkgfile
    python
    python-pip
    python-pipx
    reflector
    ripgrep
    ripgrep-all
    rsync
    smartmontools
    terminus-font
    tree
    ttf-liberation
    unrar
    unzip
    vim
    wget
    xclip
    zathura
    zip
); /usr/bin/sudo /usr/bin/pacman --sync --needed "${pkgs_pacman[@]}"



pkgs_aur=(
    git-credential-oauth
    pacseek-bin
    sublime-text-4
); /usr/bin/pikaur --sync --needed --noconfirm --noedit --nodiff "${pkgs_aur[@]}"

