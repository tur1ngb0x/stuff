#!/usr/bin/env bash

TARGET_PROTEIN="30"

# Name|Cost|Weight|Serving|Protein
items=(
  "Asitis, Micellar Casein|1526|1000|32|25"
  "Asitis, Soy Isolate|1720|2000|35|30"
  "Maxn, Whey Concentrate|2551|907|33|24"
  "Nutrabox, Soy Isolate|1300|1000|34|30"
  "SuperYou, Yeast Protein|2100|1000|33|27.03"
# "Amul, High Protein Lassi|30|200|200|15"
# "DesiFarms, Low Fat Dahi|24|400|100|4"
# "MilkyMist, Low Fat Paneer|100|200|200|50"
# "MilkyMist, Soy Tofu|50|200|200|31"
# "Relish, Chicken Breast|360|900|100|22"
# "Saffola, Soya Chunks|200|1000|100|52"
# "Unbranded, Whole Eggs|60|300|100|12"
)

# --------------------------------------------------------------------
# Internal columns:
#   1 = Item
#   2 = Cost
#   3 = Weight
#   4 = Serving
#   5 = Protein
#   6 = Protein(30g)
#   7 = SortKey
#
# Display order (change as desired):
DISPLAY_COLUMNS="6,1,2,3,4,5"
RIGHT_ALIGN_COLUMNS="1,3,4,5,6"
# --------------------------------------------------------------------

printf '\n'
printf 'Cost of %sg protein = (Cost / Weight) x (Serving / Protein) x %s\n' \
    "${TARGET_PROTEIN}" \
    "${TARGET_PROTEIN}"
printf '\n'

{
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "Item" \
        "Cost" \
        "Weight" \
        "Serving" \
        "Protein" \
        "Protein(${TARGET_PROTEIN}g)" \
        "SortKey"

    for item in "${items[@]}"; do
        IFS='|' read -r name C W S P <<< "${item}"

        IFS=$'\t' read -r S_FMT P_FMT INR <<< "$(
            awk \
                -v C="${C}" \
                -v W="${W}" \
                -v S="${S}" \
                -v P="${P}" \
                -v N="${TARGET_PROTEIN}" \
                'BEGIN {
                    printf "%.2f\t%.2f\t%.2f",
                           S,
                           P,
                           (C / W) * (S / P) * N
                }'
        )"

        printf '%s\t%s₹\t%sg\t%sg\t%sg\t%s₹\t%s\n' \
            "${name}" \
            "${C}" \
            "${W}" \
            "${S_FMT}" \
            "${P_FMT}" \
            "${INR}" \
            "${INR}"
    done
} |
{
    IFS= read -r header
    printf '%s\n' "${header}"
    sort -t $'\t' -k7,7g
} |
awk -F'\t' -v cols="${DISPLAY_COLUMNS}" '
BEGIN {
    OFS = "\t"
    n = split(cols, c, ",")
}
{
    for (i = 1; i <= n; i++) {
        printf "%s", $(c[i])
        printf (i == n ? ORS : OFS)
    }
}
' |
column -t -s $'\t' -R "${RIGHT_ALIGN_COLUMNS}"

printf '\n'
