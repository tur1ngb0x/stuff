#!/usr/bin/env bash

command atool --list "${1:?}"

read -r -p "Proceed? (N/yes): " ans

[[ "${ans}" != "yes" ]] && exit 1

command atool --verbose --explain --extract --force --subdir "${1:?}"
