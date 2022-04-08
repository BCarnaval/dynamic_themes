# TO ADD :
# --> Make linux proof (set_mac_wallpaper.scpt, setup_in_terminal.scpt)

# __________________SCRIPT__________________

directory=$1 # Directory of images
bot_sched=$2 # Bottom hour limit
top_sched=$3 # Top hour limit
shift_input=$4 # Shift in images marshal

build_images_array () {
    array=()
    idx=0
    for i in ${directory}*; do
        array+=("${i%%.*}"_${idx}".${i##*.}")
        let "idx+=1"
    done

    # Add 1 to array length
    length=$(expr ${#array[@]} '+' 1)
}

hours_to_schedule () {
    if [[ ${bot_sched} -ge ${top_sched} ]]; then
        schedule=$(expr ${top_sched} '-' ${bot_sched} '+' 24)
    else
        schedule=$(expr ${top_sched} '-' ${bot_sched})
    fi
}

get_clock_hour () {
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

    # Live shift between start of schedule and time
    shift=$(echo "(${now_h} - ${bot_sched}) * 60 + ${now_m}" | bc)
}

get_frm_number () {
    if [[ ${schedule} -gt ${#array[@]} ]]; then
        hours_between_frms=$(expr ${schedule} '/' ${length})

        # Hours as a decimal number to compute exact time between frms
        decimal=$(echo "scale=2; ${schedule} / ${length} * 60" | bc)
        minutes_between_frms=$(echo "scale=0; (${decimal} - \
                                        (${hours_between_frms} * 60))/1" | bc)

        # Total minutes between frms
        total=$(echo "${hours_between_frms} * 60 + \
                                                ${minutes_between_frms}" | bc)
        # Get actual frame number
        frm_number=$(expr ${shift_input} '+' ${shift} '/' ${total})
    else #TODO: Computes for this case.
        frms_per_hour_shifted=$(expr ${length} '/' ${schedule}) # Frame(s)/hour

        # Delay (in minutes)
        delay_between_frms=$(expr 60 '/' ${frms_per_hour_shifted})

        # Outputs the proper number of the file according to $shift
        frm_number=$(expr ${shift_input} '+' ${bot_sched} '+' ${shift} '*' \
                                                    ${frms_per_hour_shifted})
    fi
}
# FIXME: Rewrite all code under this line.
if [[ ${frame_number} -gt ${#array[@]} ]]; then
    redefining=$(expr ${frame_number} '-' ${#array[@]})
    frame_number_shifted=$(expr 1 '+' ${redefining} '/' ${frms_per_hour_shifted})
elif [[ ${frame_number} -lt 0 ]]; then
    frame_number_shifted=${frame_number#-}
else
    frame_number_shifted=${frame_number}
fi

for file in ${array[@]}; do
    if [[ "${file}" == *"_${frame_number_shifted}."* ]]; then
        setting_frame=${file}
    fi
done

cd ${HOME}
# Delete old css present in /dynamic_themes/current_css/
rm dynamic_themes/current_css/*
# Inserting the new one
cp ${directory}${setting_frame} dynamic_themes/current_css

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

# Change MacBook's Wallpaper using applescript
osascript dynamic_themes/set_mac_wallpaper.scpt
# Generates .css to setup terminal's theme and sets it
osascript dynamic_themes/setup_in_terminal.scpt
