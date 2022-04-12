#!/usr/bin/env bash

# Colors used in terminal messages
RED="$(printf '\033[31m')"
GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')"
CYAN="$(printf '\033[36m')"
WHITE="$(printf '\033[37m')"

# Default variables
BOT_SCHED=0
TOP_SCHED=24
SHIFT_IN=0

reset_terminal () {
    tput init
}

build_images_array () {
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
        echo -e "${RED}[X] No images has been found in: ${WHITE}${DIRECTORY}"
        exit 0
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
    total=$(echo "${hours_between_frms} * 60 + \
                                            ${minutes_between_frms}" | bc)
    # Get actual frame number
    frm_number=$(expr ${SHIFT_IN} '+' ${shift} '/' ${total})

    # If frame number's above maximum frame number of given directory -> set 
    # to last image
    if [[ ${frm_number} -gt ${length} ]]; then
        frm_number=$(expr ${length} '-' 1)
    fi

    # Find images that fits the right frame number
    for image in ${ARRAY[@]}; do
        if [[ "${image}" == *"_${frm_number}."* ]]; then
            ARRAY_FRM=${image}
        fi
    done
}

set_frm_from_dir () {
    progress=("#")
    for image in ${DIRECTORY}*; do
        case ${ARRAY_FRM} in
            *"${image%.*}"*)
                SET_FRM=${image}
                ;;
            *)
                echo -e "${WHITE}Browsing directory: ${GREEN}${progress[*]}"
                progress+="#"
                sleep 0.05
                clear
                ;;
        esac
    done

    if [[ "${SET_FRM}" ]]; then
        echo -e "${GREEN}[@] Using image: ${WHITE}${SET_FRM}"
        reset_terminal
    else
        echo -e "${RED}[X] No files matches frame number in: ${WHITE}${DIRECTORY}"
        reset_terminal
        exit 0
    fi
}

set_cron_task () {
    # Delete old css present in /dynamic_themes/current_css/
    rm dynamic_themes/current_css/*
    # Inserting the new one
    cp ${DIRECTORY}${SET_FRM} dynamic_themes/current_css

    # Delete previous cron job
    crontab -l | grep -v 'bash dynamic_themes/test.sh' | crontab -
    # Write out current crontab
    crontab -l > mycron
    # Echo new cron into cron file
    echo "*/${delay_between_frms} * * * * bash dynamic_themes/test.sh ${1} ${2} ${3} ${4}" >> mycron
    # Install new cron file
    crontab mycron
    # Delete mycron file
    rm mycron
}

main () {
    build_images_array
    get_hours_to_schedule
    get_clock_shift
    get_frm_in_array
    set_frm_from_dir
}

# Usage
usage () {
    clear
    man ./man_page.1
}

# Get command line options
while getopts ":d:i:s:h" opt; do
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
        h)
            usage
            exit 0
            ;;
        \?)
            echo -e "${RED}[X] Unknown option '${OPTARG}': ${WHITE}run $(basename $0) -h"
            reset_terminal
            exit 1
            ;;
        :)
            echo -e "${ORANGE}[!] Invalid: ${WHITE}-$OPTARG requires an argument."
            reset_terminal
            exit 1
            ;;
    esac
done

# Main conditionnal run
if [[ "$DIRECTORY" ]]; then
    main
else
    usage
    exit 1
fi
