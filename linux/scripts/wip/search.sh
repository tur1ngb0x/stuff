#readonly browser="org.mozilla.firefox"
readonly browser="com.brave.Browser"

encode() {
    local s="${*}"
    s="${s// /+}"
    printf "%s" "${s}"
}

google() {
    local query="${*}"
    local encoded
    encoded="$(encode "${query}")"
    printf "https://www.google.com/search?q=%s" "${encoded}"
}

youtube() {
    local query="${*}"
    local encoded
    local filter
    encoded="$(encode "${query}")"
    filter="sp=EgIQAQ%253D%253D"
    printf '%s' "https://www.youtube.com/results?search_query=${encoded}&${filter}"
}

main() {
    local provider="${1}"
    shift

    if [[ "$#" -eq 0 ]]; then
        printf 'usage: search.sh <google|youtube> <query>\n'
        exit
    fi

    local url

    case "${provider}" in
        google) url="$(google "${@}")";;
        youtube) url="$(youtube "${@}")";;
        *) printf 'unknown provider\n'; exit;;
    esac

	(nohup "${browser}" "${url}" &) &>/dev/null
}

main "${@}"
