#!/usr/bin/env bash

set -euo pipefail

usage() {
cat <<'EOF'
unicode.sh - Inspect Unicode code points in a UTF-8 text file

Usage:
    unicode.sh [--summary] FILE

Options:
    --summary    Print only summary statistics
    -h,--help    Show this help
EOF
}

summary=0
case "${1:-}" in
    -h|--help) usage; exit 0;;
    --summary) summary=1; shift;;
esac

[[ $# -eq 1 ]] || { usage >&2; exit 2; }
[[ -f "$1" ]] || { echo "Error: not a file: $1" >&2; exit 2; }

perl -CS -Mutf8 -MUnicode::UCD=charinfo -e '
use strict;
use warnings;

my %hidden = (
0x200B=>"<ZWSP>",0x200C=>"<ZWNJ>",0x200D=>"<ZWJ>",
0x2060=>"<WJ>",0xFEFF=>"<BOM>",0x200E=>"<LRM>",
0x200F=>"<RLM>",0x202A=>"<LRE>",0x202B=>"<RLE>",
0x202D=>"<LRO>",0x202E=>"<RLO>",0x2066=>"<LRI>",
0x2067=>"<RLI>",0x2068=>"<FSI>",0x2069=>"<PDI>",
0x034F=>"<CGJ>"
);

my ($lines,$ascii_lines,$non_ascii_lines)= (0,0,0);
my ($ascii,$non_ascii,$codepoints)= (0,0,0);
my (%cat,%freq,@rows);

open(my $fh,"<:encoding(UTF-8)",shift) or die $!;

while(my $line=<$fh>){
    ++$lines;
    my $has=0;
    my $col=0;
    for my $ch (split //,$line){
        ++$col;
        ++$codepoints;
        my $cp=ord($ch);
        if($cp<=0x7F){ ++$ascii; next; }
        ++$non_ascii;
        $has=1;
        my $i=charinfo($cp);
        my $cat=$i->{category}//"?";
        my $name=$i->{name}//"<unknown>";
        ++$cat{$cat};
        ++$freq{$cp};
        my $disp=exists($hidden{$cp})?$hidden{$cp}:$ch;
        push @rows,[$lines,$col,$cp,$cat,$name,$disp];
    }
    $has ? ++$non_ascii_lines : ++$ascii_lines;
}
close($fh);

unless($ARGV[0] && $ARGV[0] eq "--summary"){
printf "%5s %5s %5s %-10s %-3s %-45s %s\n",
"COUNT","LINE","COL","CODEPOINT","CAT","NAME","CHAR";
my $n=0;
for(@rows){
    ++$n;
    printf "%5d %5d %5d U+%04X %-3s %-45s %s\n",
    $n,$_->[0],$_->[1],$_->[2],$_->[3],$_->[4],$_->[5];
}
}

print "\nStatistics\n----------\n";
printf "Lines                : %d\n",$lines;
printf "ASCII lines          : %d\n",$ascii_lines;
printf "Non-ASCII lines      : %d\n",$non_ascii_lines;
printf "Code points          : %d\n",$codepoints;
printf "ASCII code points    : %d\n",$ascii;
printf "Non-ASCII codepoints : %d\n",$non_ascii;

print "\nCategories\n----------\n";
for my $k (sort keys %cat){
    printf "%-3s %d\n",$k,$cat{$k};
}

print "\nTop Code Points\n---------------\n";
my $shown=0;
for my $cp (sort {$freq{$b}<=>$freq{$a} || $a<=>$b} keys %freq){
    my $i=charinfo($cp);
    printf "%4d U+%04X %-40s\n",$freq{$cp},$cp,$i->{name}//"";
    last if ++$shown==10;
}
' "$1" "${summary:+--summary}"
