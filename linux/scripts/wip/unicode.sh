#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
unicode.sh
    Print non-ascii characters and statistics

Usage:
    unicode.sh <filename>

Options:
    -h, -help, --h, --help      Show this help message.

Examples:
    unicode.sh input.txt
EOF
}

print-lines() {
    local file_path=""
    file_path="${1}"

    perl -CS -Mutf8 -e '
        use strict;
        use warnings;

        my $file = shift @ARGV;
        open(my $fh, "<:encoding(UTF-8)", $file) or die "Error: cannot open file: $file\n";

        my $lineno = 0;
        my $n = 0;

        while (my $line = <$fh>) {
            $lineno++;

            my $colno = 0;

            my @c = split(//, $line);
            for my $ch (@c) {
                $colno++;

                next if ord($ch) <= 0x7F;
                $n++;

                printf "\e[2;38;5;245mN%d:L%d:C%d:%s:\e[0m%s\n",
                    $n,
                    $lineno,
                    $colno,
                    sprintf("U+%04X", ord($ch)),
                    $ch;
            }
        }

        close($fh);
    ' "${file_path}" || true
}

print-stats() {
    local file_path=""
    file_path="${1}"

    perl -CS -Mutf8 -e '
        use strict;
        use warnings;

        my $file = shift @ARGV;
        open(my $fh, "<:encoding(UTF-8)", $file) or die "Error: cannot open file: $file\n";

        my ($lines, $chars, $ascii, $non_ascii) = (0, 0, 0, 0);
        my ($ascii_lines, $non_ascii_lines) = (0, 0);

        while (my $line = <$fh>) {
            $lines++;

            my $line_has_non_ascii = 0;

            my @c = split(//, $line);
            for my $ch (@c) {
                $chars++;
                if (ord($ch) <= 0x7F) {
                    $ascii++;
                } else {
                    $non_ascii++;
                    $line_has_non_ascii = 1;
                }
            }

            if ($line_has_non_ascii) {
                $non_ascii_lines++;
            } else {
                $ascii_lines++;
            }
        }

        close($fh);

        sub floor2 {
            my ($x) = @_;
            return int($x * 100) / 100;
        }

        my $line_ratio = $ascii_lines ? ($non_ascii_lines / $ascii_lines) : 0.00;
        my $char_ratio = $ascii ? ($non_ascii / $ascii) : 0.00;

        my $w   = 15;
        my $dim = "\e[2;38;5;245m";
        my $rst = "\e[0m";

        print "\n";
        printf "${dim}%*s${rst}%d\n",   $w, "total_lines = ",  $lines;
        printf "${dim}%*s${rst}%d\n",   $w, "ascii_lines = ",  $ascii_lines;
        printf "${dim}%*s${rst}%d\n",   $w, "!ascii_lines = ", $non_ascii_lines;
        printf "${dim}%*s${rst}%.2f\n", $w, "line_ratio = ",   floor2($line_ratio);

        print "\n";
        printf "${dim}%*s${rst}%d\n",   $w, "total_chars = ",  $chars;
        printf "${dim}%*s${rst}%d\n",   $w, "ascii_chars = ",  $ascii;
        printf "${dim}%*s${rst}%d\n",   $w, "!ascii_chars = ", $non_ascii;
        printf "${dim}%*s${rst}%.2f\n", $w, "char_ratio = ",   floor2($char_ratio);
    ' "${file_path}"
}


main() {
    case "${1:-}" in --help|--h|-help|-h) usage; exit 0;; esac

    if [[ $# -ne 1 ]]; then
        usage 1>&2
        exit 2
    fi

    if [[ ! -f "${1}" ]]; then
        echo "Error: not a file: ${1}" 1>&2
        exit 2
    fi

    print-lines "${1}" | column -t -s ':' -o $'\t' -N COUNT,LINE,COLUMN,CODEPOINT,CHARACTER -R 1,2,3,4
    #for i in {1..80}; do printf "-"; done; printf "\n"
    print-stats "${1}"
}

main "${@}"


# tput rev; echo 'FILE:LINE:NON-ASCII'; tput sgr0
# /usr/bin/grep --color=auto -P -H -n -o '[^\x00-\x7F]' "${1}"

# tput rev; echo 'COUNT NON-ASCII'; tput sgr0
# /usr/bin/grep --color=auto -c -P '[^\x00-\x7F]' "${1}"
