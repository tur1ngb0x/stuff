set -euo pipefail

targets=(
    sleep.target
    hybrid-sleep.target
    suspend.target
    suspend-then-hibernate.target
    hibernate.target
)

usage() { echo "Usage: $0 {mask|unmask}"; exit; }

[[ $# -eq 1 ]] || usage

case "$1" in
    mask)   sudo systemctl mask   "${targets[@]}" ;;
    unmask) sudo systemctl unmask "${targets[@]}" ;;
    *)      usage ;;
esac
