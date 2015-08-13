mpd() {
    cur_song=$(basename "$(mpc current)" | sed "s/^\(.*\)\..*$/\1/")
    icon f025
    if [ -z "$cur_song" ]; then
        echo "Stopped"
    else
        paused=$(mpc | grep paused)
        [ -z "$paused" ] && toggle="${AC}mpc pause${AB}$(icon f04c)${AE}" ||
            toggle="${AC}mpc play${AB}$(icon f04b)${AE}"
        prev="${AC}mpc prev${AB}$(icon f049)${AE}"
        next="${AC}mpc next${AB}$(icon f050)${AE}"
        cur_song="${AC}${AB}$cur_song${AE}"
        echo "$cur_song $prev $toggle $next"
    fi
}

while :; do
    echo "M$(block $(mpd))" && sleep 1;
done
