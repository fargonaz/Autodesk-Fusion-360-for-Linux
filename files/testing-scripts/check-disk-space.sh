#!/bin/bash

function check_disk_space {
    # Set the directory to check
    local SELECTED_DIRECTORY="$HOME"  # Replace with the actual directory
    local GREEN="\033[0;32m"
    local YELLOW="\033[1;33m"
    local RED="\033[0;31m"
    local NOCOLOR="\033[0m"

    # Debug output
    echo -e "${YELLOW}Checking disk space for directory: $SELECTED_DIRECTORY${NOCOLOR}"

    # Get the free disk space in the selected directory
    local GET_DISK_SPACE
    GET_DISK_SPACE=$(df -h "$SELECTED_DIRECTORY" 2>/dev/null | awk 'NR==2 {print $4}')

    if [[ -z "$GET_DISK_SPACE" ]]; then
        echo -e "${RED}Failed to retrieve disk space information. Ensure the directory exists and try again.${NOCOLOR}"
        exit 1
    fi

    echo -e "${GREEN}The free disk memory size is: $GET_DISK_SPACE${NOCOLOR}"

    # Extract numerical value and unit, and replace comma with dot
    local DISK_SPACE_NUM
    local DISK_SPACE_UNIT
    DISK_SPACE_NUM=$(echo "$GET_DISK_SPACE" | sed 's/[A-Za-z]//g' | sed 's/,/./g')
    DISK_SPACE_UNIT=$(echo "$GET_DISK_SPACE" | sed 's/[0-9.,]//g')

    # Convert to gigabytes
    local DISK_SPACE_GB
    case $DISK_SPACE_UNIT in
        G) DISK_SPACE_GB=$DISK_SPACE_NUM ;;
        M) DISK_SPACE_GB=$(echo "scale=2; $DISK_SPACE_NUM / 1024" | bc) ;;
        T) DISK_SPACE_GB=$(echo "scale=2; $DISK_SPACE_NUM * 1024" | bc) ;;
        *) DISK_SPACE_GB=0 ;;
    esac

    # Check if the free disk space is greater than 10GB
    if (( $(echo "$DISK_SPACE_GB > 10" | bc -l) )); then
        echo -e "${GREEN}The free disk memory size is greater than 10GB.${NOCOLOR}"
    else
        echo -e "${YELLOW}There is not enough disk free memory to continue installing Fusion on your system!${NOCOLOR}"
        echo -e "${YELLOW}Make more space in your selected disk or select a different hard drive.${NOCOLOR}"
        echo -e "${RED}The installer has been terminated!${NOCOLOR}"
        exit 1
    fi
}

check_disk_space
