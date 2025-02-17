#!/bin/bash

# Function to convert bytes to a human-readable format
function con() {
    local -i bytes=$1
    if (( bytes < 1024 )); then
        echo "${bytes}B"
    elif (( bytes < 1048576 )); then
        echo "$(( (bytes + 1023) / 1024 ))KB"
    elif (( bytes < 1073741824 )); then
        echo "$(( (bytes + 1048575) / 1048576 ))MB"
    else
        echo "$(( (bytes + 1073741823) / 1073741824 ))GB"
    fi
}

# Print table header
echo "◇━━━━━━━━━━━━━━━━━◇"
echo "|🔸user | Quota | IP Limit🔸|"
echo "◇━━━━━━━━━━━━━━━━━◇"

# Read account data from configuration
mapfile -t data < <(grep '^#!' "/etc/xray/config.json" | cut -d ' ' -f 2 | sort -u)

# Process each account
for user in "${data[@]}"; do
    # Extract relevant information
    exp=$(grep -wE "^#! $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort -u)

    # Check if IP limit file exists, otherwise set a default message
    iplimit="No limit"  # Default value if file doesn't exist or is empty
    if [[ -f "/etc/kyt/limit/trojan/ip/${user}" ]]; then
        iplimit=$(<"/etc/kyt/limit/trojan/ip/${user}")
        
        # Handle case where file is empty
        if [[ -z "$iplimit" ]]; then
            iplimit="No limit"
        fi
    fi

    # Check if data for byte usage exists, otherwise set it to 0
    if [[ -f "/etc/trojan/${user}" ]]; then
        byte=$(<"/etc/trojan/${user}")
    else
        byte=0
    fi
    lim=$(con "${byte}")

    # Check if quota limit file exists, otherwise set it to 0
    if [[ -f "/etc/limit/trojan/${user}" ]]; then
        wey=$(<"/etc/limit/trojan/${user}")
    else
        wey=0
    fi
    gb=$(con "${wey}")

    # Print account information in a formatted manner
    printf "%-10s %-12s %-10s\n" "${user}" "${gb}/${lim}" "${iplimit} IP"
done

# Exit script
exit 0
