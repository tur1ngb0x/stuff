_profile_xdg () {
    XDG_CACHE_HOME="${HOME}/.cache";       builtin export XDG_CACHE_HOME;  /usr/bin/mkdir -p "${XDG_CACHE_HOME}"  # cache directory
    XDG_CONFIG_HOME="${HOME}/.config";     builtin export XDG_CONFIG_HOME; /usr/bin/mkdir -p "${XDG_CONFIG_HOME}" # config directory
    XDG_DATA_HOME="${HOME}/.local/share";  builtin export XDG_DATA_HOME;   /usr/bin/mkdir -p "${XDG_DATA_HOME}"   # data directory
    XDG_STATE_HOME="${HOME}/.local/state"; builtin export XDG_STATE_HOME;  /usr/bin/mkdir -p "${XDG_STATE_HOME}"  # state directory
    XDG_APP_HOME="${HOME}/.apps";          builtin export XDG_APP_HOME;    /usr/bin/mkdir -p "${XDG_APP_HOME}"    # apps gui directory
    XDG_BIN_HOME="${HOME}/.local/bin";     builtin export XDG_BIN_HOME;    /usr/bin/mkdir -p "${XDG_BIN_HOME}"    # apps cli directory
}

_profile_freetype () {
    FREETYPE_PROPERTIES=""

    # thickens non cff fonts, small text is easier to see | greyscale + cleartype
    FREETYPE_PROPERTIES="${FREETYPE_PROPERTIES}autofitter:no-stem-darkening=0 "
    # 0   = stem darkening on, strokes look thicker
    # 1   = stem darkening off, strokes keep original weight

    # thickens cff fonts, small text is easier to see | greyscale + cleartype
    FREETYPE_PROPERTIES="${FREETYPE_PROPERTIES}cff:no-stem-darkening=0 "
    # 0   = stem darkening on, strokes look thicker
    # 1   = stem darkening off, strokes keep original weight

    # preserves non cff font shapes, looks closer to the original | greyscale + cleartype
    FREETYPE_PROPERTIES="${FREETYPE_PROPERTIES}autofitter:warping=0 "
    # 0   = no warping, shapes stay closer to original
    # 1   = warping on, shapes bend to fit pixels

    # preserves truetype font shapes, looks closer to the original | greyscale + cleartype
    FREETYPE_PROPERTIES="${FREETYPE_PROPERTIES}truetype:warping=0 "
    # 0   = no warping, shapes stay closer to original
    # 1   = warping on, shapes bend to fit pixels

    # thickens thin lines of truetype fonts | greyscale only
    FREETYPE_PROPERTIES="${FREETYPE_PROPERTIES}truetype:gray-strong-stem-widths=1 "
    # 0   = normal stem strength in greyscale
    # 1   = stronger stems in greyscale

    # uses modern windows style truetype hinting | greyscale + cleartype
    FREETYPE_PROPERTIES="${FREETYPE_PROPERTIES}truetype:interpreter-version=40"
    # 35  = old truetype hinting behavior
    # 40  = modern windows style hinting behavior

    builtin export FREETYPE_PROPERTIES
}

_profile_xrandr () {
        /usr/bin/xrandr --output HDMI-1 --primary --size '1920x1080' --refresh '60' --dpi '96' # set resolution, frequency, dpi
        /usr/bin/xrandr --output HDMI-1 --set 'Broadcast RGB' 'Full'                           # set rgb range to 0-255
        /usr/bin/xrandr --output HDMI-1 --set 'audio' 'off'                                    # disable audio
}

_profile_xset () {
    /usr/bin/xset +dpms        # enable dpms support
    /usr/bin/xset dpms 300 0 0 # standby after 300s, disable suspend, disable poweroff
    /usr/bin/xset m 0 0        # disable mouse acceleration
}

_profile_wine () {
    WINEPREFIX="${HOME}/src/wine/default"; builtin export WINEPREFIX; /usr/bin/mkdir -p "${WINEPREFIX}"
}

_profile_bash() {
    /usr/bin/mkdir -p "${XDG_STATE_HOME}/bash"
    HISTFILE="${XDG_STATE_HOME}/bash/history"
    builtin export HISTFILE
    [[ -f "${HOME}/.bashrc" ]] && . "${HOME}/.bashrc"
}

main() {
    _profile_xdg
    _profile_wine
    _profile_xrandr
    _profile_bash
}

main "${@}" >/dev/null 2>&1
