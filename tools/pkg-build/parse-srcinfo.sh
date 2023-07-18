#!/bin/bash

file_path="$1"
sections=()
declare -A base
declare -A config

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ $line =~ ^\s*# ]]; then
        continue
    fi

    if [[ $line == pkgname* ]]; then
        declare -A config
        sections+=("$config")
    fi

    if [[ $line =~ ^\s*(.+)\s*=\s*(.*)\s*$ ]]; then
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]}
        # Trim leading and trailing whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        echo "$key=$value"
        if [[ -v config[$key] ]]; then
                if [[ ! ${config[$key]} =~ \[* ]]; then
                    config[$key]=("${config[$key]}")
                fi
                config[$key]+="$value"
        else
            config[$key]="$value"
        fi
    fi
done < "$file_path"

echo "Base: ${!base[@]}"

for section in "${sections[@]}"; do
        for key in "${!base[@]}"; do
            if [[ ! ${section[$key]} ]]; then
                section[$key]="${base[$key]}"
            else
                if [[ ! ${section[$key]} =~ \[* ]]; then
                    section[$key]=("${section[$key]}")
                fi
                section[$key]+="${base[$key]}"
            fi
        done
done

echo "${sections[@]}"
