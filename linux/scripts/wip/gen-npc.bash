#!/usr/bin/env bash

# --- NPC Schema Definitions and Mappings ---
sex=(F M)
declare -A sex_map=(
    [F]="Female"
    [M]="Male"
)

ethnicity=(A B H I M W)
declare -A ethnicity_map=(
    [A]="Asian"
    [B]="Black"
    [H]="Hispanic"
    [I]="Indian"
    [M]="MiddleEastern"
    [W]="White"
)

age=(O Y)
declare -A age_map=(
    [O]="Old"
    [Y]="Young"
)

profession=(C E G R)
declare -A profession_map=(
    [C]="Civilian"
    [E]="Emergency"
    [G]="Gangster"
    [R]="Rich"
)

area=(R S U)
declare -A area_map=(
    [R]="Rural"
    [S]="Suburban"
    [U]="Urban"
)

# --- Random Picker ---
pick_random() {
    local arr=("$@")
    echo "${arr[RANDOM % ${#arr[@]}]}"
}

# --- Generate NPC ---
generate_npc() {
    local s=$(pick_random "${sex[@]}")
    local e=$(pick_random "${ethnicity[@]}")
    local a=$(pick_random "${age[@]}")
    local p=$(pick_random "${profession[@]}")
    local ar=$(pick_random "${area[@]}")

    local code="${s}${e}${a}${p}${ar}"
    local desc="${sex_map[$s]}\t${ethnicity_map[$e]}\t${age_map[$a]}\t${profession_map[$p]}\t${area_map[$ar]}"

    echo -e "$code\t$desc"
}

generate_npcs() {
    local count=${1:-10}

    # total combinations
    local max=$(( ${#sex[@]} * ${#ethnicity[@]} * ${#age[@]} * ${#profession[@]} * ${#area[@]} ))

    # safety guard
    if (( count > max )); then
        echo "Error: requested $count NPCs, but only $max unique combinations possible" >&2
        exit 1
    fi

    declare -A seen=()
    local i=0

    while (( i < count )); do
        line=$(generate_npc)
        code=${line%%$'\t'*}

        if [[ -z "${seen[$code]}" ]]; then
            seen[$code]=1
            echo "$line"
            ((i++))
        fi
    done
}

# --- Run ---
generate_npcs "$1" | column -t -s $'\t'
