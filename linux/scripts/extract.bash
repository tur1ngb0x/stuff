#!/usr/bin/env bash

atool --list "${1:?}"

read -r -p "Proceed? (N/yes): " ans; [[ "${ans}" == yes ]] || exit 1

atool --explain --extract --force --subdir "${1:?}"
