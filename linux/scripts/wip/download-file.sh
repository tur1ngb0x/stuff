#!/usr/bin/env bash

# default help function
usage()
{
    cat << EOF
DESCRIPTION
    Download files using download managers
SYNTAX
    ${0##*/} <url> </path/to/the/filename>
USAGE
    ${0##*/} 'raw.githubusercontent.com/torvalds/linux/master/README' '~/user/Downloads/readme.md'
    ${0##*/} 'raw.githubusercontent.com/torvalds/linux/master/README' './readme.md'
EOF
}

# if no arguments, print help and exit
if [[ "${#}" -eq 0 ]]; then
    usage
    exit
fi

# check for download helpers
for program in aria2c axel curl wget2 wget; do
    if command -v "${program}"; then
        echo "${program} found"
        downloader="${program}"
        break
    else
        echo "${program} not found"
    fi
done

# exit script if no download helpers installed
if [[ -z "${downloader}" ]]; then
    echo "Please install any one of them to continue"
    exit
fi

# print the download helper
tput rev; echo " downloading ${1} using ${downloader} to ${2}"; tput sgr0

# download file according to the download helper
case "${downloader}" in
    aria2c)	aria2c	 "${1}"	-o	"${2}" ;;
    axel)	axel	 "${1}"	-o	"${2}" ;;
    curl)	curl	 "${1}"	-o	"${2}" ;;
    wget2)	wget2	 "${1}"	-O	"${2}" ;;
    wget)	wget	 "${1}"	-O	"${2}" ;;
esac
