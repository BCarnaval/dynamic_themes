#!/usr/bin/env bash

# Author  : Antoine de Lagrave
# Mail    : antoinedelagrave@hotmail.com
# Github  : @BCarnaval

# dynamic_themes : Sets wallpaper, terminal & IDE themes
# Sheduled using Python background daemon.

RED="$(printf '\033[31m')" GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')" CYAN="$(printf '\033[36m')"
WHITE="$(printf '\033[37m')"

BOT_SCHED=0
TOP_SCHED=24
SHIFT_IN=0
CURRENT_DIR=$( pwd )
PROJECT_DIR=/usr/local/share/dynamic_themes

reset_terminal () {
    tput init
}

# Exit if 'pywal' not found on machine
check_pywal() {
    if [[ -x $( command -v wal ) ]]; then
        reset_terminal
        clear
    else
        echo -e "${RED}[X] 'pywal' is not installed on your system:${WHITE} exiting..."
        reset_terminal
        clear
        exit 1
    fi
}

clean_images_names () {
    cd ${DIRECTORY}
    for file in *; do
        if [[ -f ${file} ]]; then
            mv "${file}" $(echo "${file}" | sed -e 's/[^A-Za-z0-9._-]/_/g')
        else
            echo -e "${RED}[X] Given directory is unreadable."
            reset_terminal
            cd ${CURRENT_DIR}
            exit 1
        fi
    done
    echo -e "${GREEN}[@] File names of given directory cleaned."
    cd ${CURRENT_DIR}
}

build_images_array () {
    clean_images_names
    ARRAY=()
    idx=1
    for file in ${DIRECTORY}*; do
        case ${file} in
            (*".png" | *".jpg" | *".jpeg" | *".tiff")
                ARRAY+=("${file%%.*}"_${idx}".${file##*.}")
                let "idx+=1"
                ;;
            *)
                echo -e "$ORANGE[!] ${file} ${WHITE}is not a valid image."
                ;;
        esac
    done
    reset_terminal

    # Verifying if array's empty
    length=$(expr ${#ARRAY[@]} '+' 1)
    if [[ ${length} -eq 1 ]]; then
        echo -e "${RED}[X] No images has been found in: ${WHITE}${DIRECTORY}."
        exit 1
    fi
}

get_hours_to_schedule () {
    if [[ ${BOT_SCHED} -ge ${TOP_SCHED} ]]; then
        SCHEDULE=$(expr ${TOP_SCHED} '-' ${BOT_SCHED} '+' 24)
    else
        SCHEDULE=$(expr ${TOP_SCHED} '-' ${BOT_SCHED})
    fi
}

get_clock_shift () {
    now_h=$(date +"%H")
    now_m=$(date +"%M")

    # Get hours as int
    if [[ "${now_h:0:1}" -eq "0" ]]; then
        now_h="${now_h:1:1}"
    fi

    # Get minutes as int
    if [[ "${now_m:0:1}" -eq "0" ]]; then
        now_m="${now_m:1:1}"
    fi

    # Live shift between start of SCHEDULE and time
    shift=$(echo "(${now_h} - ${BOT_SCHED}) * 60 + ${now_m}" | bc)
}

get_frm_in_array () {
    hours_between_frms=$(expr ${SCHEDULE} '/' ${length})

    # Hours as a decimal number to compute exact time between frms
    decimal=$(echo "scale=2; ${SCHEDULE} * 60 / ${length}" | bc)
    minutes_between_frms=$(echo "scale=0; (${decimal} - \
                                    (${hours_between_frms} * 60))/1" | bc)

    # Total minutes between frms
    TOTAL=$(echo "${hours_between_frms} * 60 + \
                                            ${minutes_between_frms}" | bc)
    echo -e "${GREEN}[@] Changing themes every: ${WHITE}${TOTAL} ${GREEN}minutes."
    frm_number=$(expr ${SHIFT_IN} '+' ${shift} '/' ${TOTAL} '+' 1)

    # If frame number's above maximum frame number of given directory -> set 
    # to last image
    if [[ ${frm_number} -gt ${length} ]]; then
        frm_number=$(expr ${length} '-' 1)
    fi
    for image in ${ARRAY[@]}; do
        if [[ "${image}" == *"_${frm_number}."* ]]; then
            ARRAY_FRM=${image}
        fi
    done
}

# Progress animation functions
sp="/-\|"
sc=0
spin() {
   printf "\r${GREEN}[@] ${1}${WHITE}${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}
endspin() {
   printf "\r%s\n" "$@"
}

set_frm_from_dir () {
    for image in ${DIRECTORY}*; do
        spin "Browsing through images..."
        sleep 0.1
        case ${ARRAY_FRM} in
            *"${image%.*}"*)
                SET_FRM=${image}
                ;;
            *)
                ;;
        esac
    done
    endspin

    if [[ "${SET_FRM}" ]]; then
        echo -e "${GREEN}[@] Using image: ${WHITE}${SET_FRM##*/} ${GREEN} as initial frame."
        reset_terminal
    else
        echo -e "${RED}[X] No files matches frame number in: ${WHITE}${DIRECTORY}."
        reset_terminal
        exit 1
    fi
}

setup_task () {
    ${PROJECT_DIR}/PyScripts/dynamiser.py start ${DIRECTORY} ${SET_FRM} ${TOTAL}
    reset_terminal
}

kill_task () {
    ${PROJECT_DIR}/PyScripts/dynamiser.py stop
    reset_terminal
}

# Usage
usage () {
    clear
    man ${PROJECT_DIR}/man_page.1
}

main () {
    check_pywal
    build_images_array
    get_hours_to_schedule
    get_clock_shift
    get_frm_in_array
    set_frm_from_dir
    setup_task
}

while getopts ":d:i:s:kh" opt; do
    case ${opt} in
        d)
            DIRECTORY=${OPTARG}
            ;;
        i)
            BOT_SCHED=${OPTARG%-*}
            TOP_SCHED=${OPTARG##*-}
            ;;
        s)
            SHIFT_IN=${OPTARG}
            ;;
        k)
            kill_task
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo -e "${RED}[X] Unknown option '${OPTARG}': ${WHITE}run $(basename $0) -h."
            reset_terminal
            exit 1
            ;;
        :)
            echo -e "${ORANGE}[!] Invalid: ${WHITE}'$OPTARG' requires an argument."
            reset_terminal
            exit 1
            ;;
    esac
done

# Main run
if [[ "$DIRECTORY" ]]; then
    main
else
    usage
    exit 0
fi
