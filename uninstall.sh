#!/usr/bin/env bash

# Colors used in terminal messages
RED="$(printf '\033[31m')"
GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')"
CYAN="$(printf '\033[36m')"
WHITE="$(printf '\033[37m')"

DESTINATION=/usr/local/share

rm_directory () {
    echo -e "${ORANGE}[!] Uninstalling dynamic_themes..."
    if [[ -d ${DESTINATION}/dynamic_themes ]]; then
        sudo rm -rf ${DESTINATION}/dynamic_themes
    fi
}

rm_symlink() {
    if [[ -L /usr/local/bin/dyth ]]; then
        sudo rm /usr/local/bin/dyth
    fi
    echo -e "${GREEN}[@] Uninstalled successfully."
}

main () {
    rm_directory
    rm_symlink
}

main