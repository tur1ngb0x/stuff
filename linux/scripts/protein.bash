# #!/usr/bin/env bash

/usr/bin/sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d;1d' ~/src/stuff/linux/scripts/protein.csv \
| while IFS=, builtin read -r product W P p C
do
    protein_gm=$(/usr/bin/awk -v p="${p}" -v C="${C}" 'BEGIN{print p*C}')

    cost_1g=$(/usr/bin/awk -v W="${W}" -v p="${p}" -v P="${P}" 'BEGIN{print P/(W*p)}')
    cost_daily=$(/usr/bin/awk -v P="${P}" -v C="${C}" -v W="${W}" 'BEGIN{print (P*C)/W}')
    cost_30g=$(/usr/bin/awk -v W="${W}" -v p="${p}" -v P="${P}" 'BEGIN{print 30*P/(W*p)}')
    cost_monthly=$(/usr/bin/awk -v P="${P}" -v C="${C}" -v W="${W}" 'BEGIN{print 30*(P*C)/W}')

    builtin printf "%s,%s,%s,%s,%s,%.2f,%.2f,%.2f,%.2f,%.2f\n" \
        "${product}" "${W}" "${P}" "${p}" "${C}" \
        "${protein_gm}" \
        "${cost_1g}" "${cost_30g}" "${cost_daily}" "${cost_monthly}"

done \
| LC_ALL=C /usr/bin/sort -t',' -k7,7n \
| /usr/bin/awk -F',' '
BEGIN{OFS=","}
{sum += $9; print}
END{printf "TOTAL,,,,,,,,%0.2f,\n", sum}
' \
| /usr/bin/column -s , -t \
-N PRODUCT,WEIGHT[g],PRICE[INR],PROTEINRATIO[0-1],DAILY[g],PROTEIN[gm],PROTEIN1G[INR],PROTEIN30G[INR],DAILY[INR],MONTHLY[INR] \
-R 2,3,4,5,6,7,8,9,10
