#!/bin/bash

set -euo pipefail

usage() {
    Treset=$(tput sgr0)
    Tbold=$(tput bold)
    Treverse=$(tput rev)

    cat <<EOF
${Treverse}${Tbold} DESCRIPTION ${Treset}
Manage media: download, convert, and edit metadata for audio/video files.

${Treverse}${Tbold} SYNTAX ${Treset}
$ ${0##*/} <command> <options>

${Treverse}${Tbold} COMMANDS ${Treset}                      ${Treverse}${Tbold} OPTIONS ${Treset}
download mp3 <url(s)>           Download mp3 file(s) from the URL(s)
download mp4 <url(s)>           Download mp4 file(s) from the URL(s)
download art <url(s)>           Download album art from the URL(s)
metadata view                   View metadata of mp3 file(s)
metadata set artist <artist>    Set artist tag on mp3 files
metadata set album <album>      Set album tag on mp3 files
metadata delete                 Delete all metadata tags from mp3 file(s)
convert a2v                     Convert all mp3 file(s) with album art to mp4 video(s)

${Treverse}${Tbold} EXAMPLES ${Treset}
$ ${0##*/} download mp3 "https://youtube.com/playlist?list=XYZ"
$ ${0##*/} metadata view
$ ${0##*/} metadata set artist "My Artist"
$ ${0##*/} metadata set album "My Album"
$ ${0##*/} convert a2v
EOF
}

download_mp3() {
    local urls=("${@}")
    for url in "${urls[@]}"; do
        echo "Downloading mp3 from ${url}"
        command yt-dlp --force-ipv4 --preset-alias mp3 \
		--audio-quality 0 --embed-thumbnail --embed-metadata \
		-o '%(playlist_index)s - %(title)s.%(ext)s' "${url}"
    done
}

download_mp4() {
    local urls=("${@}")
    for url in "${urls[@]}"; do
        echo "Downloading mp4 from ${url}"
        command yt-dlp --force-ipv4 --preset-alias mp4 \
		--prefer-free-formats --sub-langs 'en.*' --embed-subs --embed-thumbnail --embed-metadata --embed-chapters \
		-o '%(title)s.%(ext)s' "${url}"
    done
}

download_albumart() {
    local urls=("${@}")
    for url in "${urls[@]}"; do
        echo "Downloading album art from ${url}"
        command yt-dlp --force-ipv4 --skip-download --playlist-items 1 --write-thumbnail --convert-thumbnails jpg -o "cover.%(ext)s" "${url}"
		cp -fv cover.jpg album.jpg
		cp -fv cover.jpg album.jpg
    done
}

metadata_view() {
    {
        # Header
        printf "%s\t%s\t%s\n" "FILE" "ARTIST" "ALBUM"
        find . -maxdepth 1 -type f -iname "*.mp3" | sort | while read -r file; do
            artist=$(ffprobe -v quiet -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$file")
            album=$(ffprobe -v quiet -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$file")
            # year=$(ffprobe -v quiet -show_entries format_tags=date -of default=noprint_wrappers=1:nokey=1 "$file")
            # track=$(ffprobe -v quiet -show_entries format_tags=track -of default=noprint_wrappers=1:nokey=1 "$file")
            # title=$(ffprobe -v quiet -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$file")
            printf "%s\t%s\t%s\n" "$(basename "$file")" "$artist" "$album"
        done
    } | column -t -s $'\t' -o '  '
}

metadata_delete() {
    echo "Type 'yes' to delete all tags from mp3 files in current directory:"
    read -r choice
    if [[ "$choice" == "yes" ]]; then
        find . -maxdepth 1 -type f -iname "*.mp3" -exec id3v2 --delete-all {} \;
        echo "All tags deleted."
    else
        echo "Skipping deletion."
    fi
}

metadata_set() {
    if [[ $# -lt 2 ]]; then
        echo "Usage:"
        echo " ${0##*/} metadata set artist <name>"
        echo " ${0##*/} metadata set album <name>"
        exit 1
    fi

    local field="$1"
    shift
    local value="$*"

    case "$field" in
        artist)
            find . -maxdepth 1 -type f -iname "*.mp3" -exec id3v2 --artist "$value" {} \;
            echo "Artist tag set to '$value' on all mp3 files."
            ;;
        album)
            find . -maxdepth 1 -type f -iname "*.mp3" -exec id3v2 --album "$value" {} \;
            echo "Album tag set to '$value' on all mp3 files."
            ;;
        *)
            echo "Invalid field: $field"
            echo "Valid options: artist, album"
            exit 1
            ;;
    esac
}

convert_mp3to4() {
    local image=""
    for img in cover.jpg cover.jpeg cover.png album.jpg album.jpeg album.png folder.jpg folder.jpeg folder.png; do
        if [[ -f "$img" ]]; then
            image="$img"
            break
        fi
    done
    if [[ -z "$image" ]]; then
        echo "Album art not found. Expected one of: cover.*, album.*, folder.*"
        exit 1
    fi

    for mp3 in *.mp3; do
        [[ -f "$mp3" ]] || { echo "No mp3 files found"; exit 1; }
        base="${mp3%.mp3}"
        echo "Converting '$mp3' to '${base}.mp4' using album art '$image'"
        ffmpeg -hide_banner -loglevel error -loop 1 -i "$image" -i "$mp3" -c:v libx264rgb -crf 0 -r 1 -tune stillimage -s 720x720 -c:a copy -preset veryslow -shortest "${base}.mp4"
    done
    echo "Conversion done."
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

cmd="$1"
shift

case "$cmd" in
    download)
        if [[ $# -lt 2 ]]; then
            echo "Usage: ${0##*/} download <mp3|mp4|art> <URL(s)>"
            exit 1
        fi
        type="$1"
        shift
        case "$type" in
            mp3) download_mp3 "${@}" ;;
            mp4) download_mp4 "${@}" ;;
            albumart) download_albumart "${@}" ;;
            *) echo "Unknown download type: $type"; usage; exit 1 ;;
        esac
        ;;
    metadata)
        if [[ $# -lt 1 ]]; then
            echo "Usage: ${0##*/} metadata <view|set|delete> [args]"
            exit 1
        fi
        meta_cmd="$1"
        shift
        case "$meta_cmd" in
            view) metadata_view ;;
            set) metadata_set "${@}" ;;
            delete) metadata_delete ;;
            *) echo "Unknown metadata command: $meta_cmd"; usage; exit 1 ;;
        esac
        ;;
    convert)
        if [[ $# -lt 1 ]]; then
            echo "Usage: ${0##*/} convert mp3to4"
            exit 1
        fi
        conv_cmd="$1"
        shift
        case "$conv_cmd" in
            mp3to4) convert_mp3to4 ;;
            *) echo "Unknown convert command: $conv_cmd"; usage; exit 1 ;;
        esac
        ;;
    *)
        echo "Unknown command: $cmd"
        usage
        exit 1
        ;;
esac
