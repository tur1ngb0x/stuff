PATH="${HOME}/src/scripts/linux:${PATH}"
PATH="${HOME}/.cargo/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"
PATH="${HOME}/.local/share/flatpak/exports/bin:${PATH}"
PATH="$(builtin printf '%s' "${PATH}" | command awk -v RS=: -v ORS= '!a[$0]++ {if (NR>1) printf(":"); printf("%s", $0) }')"
builtin export PATH

# note: topmost line will be appended at the last of existing PATH
# PATH="$PATHNAME1:$PATH"
# PATH="$PATHNAME2:$PATH"
# PATH="$PATHNAME3:$PATH"
# note: last line will be appended at the first of the existing PATH
# PATH="$PATHNAME3:$PATHNAME2:$PATHNAME1:$PATH"
