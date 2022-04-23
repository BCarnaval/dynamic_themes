#!/usr/bin/env bash

# Author  : Antoine de Lagrave
# Email    : antoinedelagrave@hotmail.com
# GitHub  : @BCarnaval

# dynamic_themes : Sets wallpaper, terminal & IDE themes
# Sheduled using Python background daemon.

RED="$(printf '\033[31m')" GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')" CYAN="$(printf '\033[36m')"
WHITE="$(printf '\033[37m')"

DIRECTORY=${1}
BOT_SCHED=${2}
SCHEDULE=${3}
SHIFT_IN=${4}

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
                ;;
        esac
    done
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
    frm_number=$(expr ${SHIFT_IN} '+' ${shift} '/' ${TOTAL} '+' 1)

    # If frame number's above maximum frame number of given directory -> set 
    # to last image
    if [[ ${frm_number} -gt ${length} ]] || [[ ${shift} -lt 0 ]]; then
        frm_number=$(expr ${length} '-' 1)
    fi
    for image in ${ARRAY[@]}; do
        if [[ "${image}" == *"_${frm_number}."* ]]; then
            ARRAY_FRM=${image}
        fi
    done
}

set_frm_from_dir () {
    for image in ${DIRECTORY}*; do
        case ${ARRAY_FRM} in
            *"${image%.*}"*)
                SET_FRM=${image}
                ;;
            *)
                ;;
        esac
    done

    if [[ "${SET_FRM}" ]]; then
        echo -e "${GREEN}[@] Using image: ${WHITE}${SET_FRM##*/}."
        reset_terminal
    else
        echo -e "${RED}[X] No files matches frame number in: ${WHITE}${DIRECTORY}."
        reset_terminal
        exit 1
    fi
}

set_shell_theme () {
    wal --backend colorz -i ${SET_FRM} -n
}

set_wallpaper_image () {
    /usr/local/share/dynamic_themes/PyScripts/_switch_wallpaper.py ${SET_FRM}
}

main () {
    build_images_array
    get_clock_shift
    get_frm_in_array
    set_frm_from_dir
    set_shell_theme
    set_wallpaper_image
}

main