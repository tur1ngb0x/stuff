IGNORE_PATHS=(
    "${HOME}/.local/share/containers"
    "${HOME}/.local/share/flatpak"
    "${HOME}/.local/share/Trash"
    "${HOME}/.var"
)

# find symlinks
for type in f d; do
    printf '%s %s %s\n' "$(tput rev)" "symlink - ${type}" "$(tput sgr0)"

    find "${HOME}" -xdev \
        \( \
            -path "${IGNORE_PATHS[0]}" -o \
            -path "${IGNORE_PATHS[1]}" -o \
            -path "${IGNORE_PATHS[2]}" -o \
            -path "${IGNORE_PATHS[3]}" \
        \) -prune -o \
        -type l -xtype "${type}" -print | LC_ALL=C sort
done

# find invalid ownership
for type in f d; do
    printf '%s %s %s\n' "$(tput rev)" "invalid ownership - ${type}" "$(tput sgr0)"

    find "${HOME}" -xdev \
        \( \
            -path "${IGNORE_PATHS[0]}" -o \
            -path "${IGNORE_PATHS[1]}" -o \
            -path "${IGNORE_PATHS[2]}" -o \
            -path "${IGNORE_PATHS[3]}" \
        \) -prune -o \
        -type "${type}" \( -not -user "${USER}" -o -not -group "${USER}" \) \
        -printf '%p : %u : %g\n' | LC_ALL=C sort
done

# find not readable
for type in f d; do
    printf '%s %s %s\n' "$(tput rev)" "not readable - ${type}" "$(tput sgr0)"

    find "${HOME}" -xdev \
        \( \
            -path "${IGNORE_PATHS[0]}" -o \
            -path "${IGNORE_PATHS[1]}" -o \
            -path "${IGNORE_PATHS[2]}" -o \
            -path "${IGNORE_PATHS[3]}" \
        \) -prune -o \
        -type "${type}" -not -readable -print | LC_ALL=C sort
done

# find not writable
for type in f d; do
    printf '%s %s %s\n' "$(tput rev)" "not writable - ${type}" "$(tput sgr0)"

    find "${HOME}" -xdev \
        \( \
            -path "${IGNORE_PATHS[0]}" -o \
            -path "${IGNORE_PATHS[1]}" -o \
            -path "${IGNORE_PATHS[2]}" -o \
            -path "${IGNORE_PATHS[3]}" \
        \) -prune -o \
        -type "${type}" -not -writable -print | LC_ALL=C sort
done

