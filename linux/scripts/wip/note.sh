#!/usr/bin/env bash

# Folder where notes are stored
NOTE_DIR="${HOME}/src/notes"

# Text editor used to open notes
NOTE_EDITOR="micro"

# Check if editor is available in PATH
if ! command -v "${NOTE_EDITOR}" &>/dev/null; then
    printf "error: %s not found in PATH\n" "${NOTE_EDITOR}"
    exit 1
fi

# Ensure note directory exists
mkdir -p "${NOTE_DIR}"

# Check that the note directory is owned by the current user
if [[ "$(stat -c '%U' "${NOTE_DIR}")" != "${USER}" ]]; then
    printf "error: %s is not owned by %s\n" "${NOTE_DIR}" "${USER}"
    exit 1
fi

# Check that the note directory is readable and writable
if [[ ! -r "${NOTE_DIR}" || ! -w "${NOTE_DIR}" ]]; then
    printf "error: %s must be readable and writable\n" "${NOTE_DIR}"
    exit 1
fi

# If no argument → browse and select an existing note
if [[ -z "${1}" ]]; then
    # Collect all note filenames into an array
    mapfile -t NOTE_FILES < <(find "${NOTE_DIR}" -mindepth 1 -maxdepth 1 -type f -printf '%f\n')

    # Stop if there are no existing notes
    if (( ${#NOTE_FILES[@]} == 0 )); then
        printf "error: no notes found in ${NOTE_DIR}\n"
        exit 1
    fi

    # Use fzf to select a note from the list
    NOTE_FILE="$(printf '%s\n' "${NOTE_FILES[@]}" | fzf --preview="bat --style=plain --color=always '${NOTE_DIR}/{}'" --preview-window=right:70%)"

    # If a note was selected, open it in the editor
    if [[ -n "${NOTE_FILE}" ]]; then
        "${NOTE_EDITOR}" "${NOTE_DIR}/${NOTE_FILE}"
    else
        printf "no note selected\n"
        exit 1
    fi

# Else → create a new note from CLI argument
else
    NOTE_FILE="$(date +"%Y%m%d-%H%M%S")_${1}.md"
    printf '\n# %s\n\n' "${1}" > "${NOTE_DIR}/${NOTE_FILE}"
    "${NOTE_EDITOR}" +4 "${NOTE_DIR}/${NOTE_FILE}"
fi
