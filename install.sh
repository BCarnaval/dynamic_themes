#!/usr/bin/env bash

# Colors used in terminal messages
RED="$(printf '\033[31m')"
GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')"
CYAN="$(printf '\033[36m')"
WHITE="$(printf '\033[37m')"

# Paths
CURRENT_DIR=$( pwd )
DESTINATION=/usr/local/share

build_directory () {
    echo -e "${GREEN}[@] Installing dynamic_themes..."
    if [[ -d "${DESTINATION}"/dynamic_themes ]]; then
        # Updating directories
        sudo rm -rf ${DESTINATION}/dynamic_themes
        sudo mkdir -p ${DESTINATION}/dynamic_themes
    else
        sudo mkdir -p ${DESTINATION}/dynamic_themes
    fi
}

fill_directory () {
    sudo cp -r ${CURRENT_DIR}/PyScripts ${DESTINATION}/dynamic_themes
    sudo cp -r ${CURRENT_DIR}/dyth.sh ${DESTINATION}/dynamic_themes
    sudo cp -r ${CURRENT_DIR}/_switch_iterm.sh ${DESTINATION}/dynamic_themes
    sudo cp -r ${CURRENT_DIR}/uninstall.sh ${DESTINATION}/dynamic_themes
    sudo cp -r ${CURRENT_DIR}/man_page.1 ${DESTINATION}/dynamic_themes

    # Make scripts executable
    sudo chmod +x ${DESTINATION}/dynamic_themes/dyth.sh
    sudo chmod +x ${DESTINATION}/dynamic_themes/uninstall.sh
    sudo chmod +x ${DESTINATION}/dynamic_themes/_switch_iterm.sh
    sudo chmod +x ${DESTINATION}/dynamic_themes/man_page.1
    for script in ${DESTINATION}/dynamic_themes/PyScripts/*; do
        if [[ -f ${script} ]]; then
            sudo chmod +x ${script}
        fi
    done

    # Create symlink
    if [[ -L /usr/local/bin/dyth ]]; then
        sudo rm /usr/local/bin/dyth
        sudo ln -s ${DESTINATION}/dynamic_themes/dyth.sh /usr/local/bin/dyth
    else
        sudo ln -s ${DESTINATION}/dynamic_themes/dyth.sh /usr/local/bin/dyth
    fi
    echo -e "${GREEN}[@] Installed successfully:${WHITE} Execute 'dyth' to verify installation."
}

main () {
    build_directory
    fill_directory
}

main