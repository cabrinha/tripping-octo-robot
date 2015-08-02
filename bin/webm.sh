#!/bin/bash
#
# Author:       Twily -> Ushibro         2014
# Waifu:  Twily likes horses, Ushibro likes Ushi and also Mio is pretty cool
# Ushi: https://mega.nz/#!dw0HEaLD!1xLyazKWiB8fpZmF-k4dn19ndw6Gv7YN_Jqo1rUPzZg
# Description:  Records a window or the desktop and converts the video to webm format.
# Requires:     ffmpeg, xwininfo, libnotify, keybind in your WM to "killall ffmpeg"
# Useage:       $ sh screencast -h|--help

MODE="desktop"                  # Default "desktop" ["window"|"desktop"]
MARGIN=0                       # Margin in window mode (px)
TITLEBAR=0                     # Titlebar height in window mode (px)
FPS=30                          # Frames Per Second [12-60]
PRESET="ultrafast"              # Default "ultrafast" (x264 --help for preset list)
CRF=10                        # Constant Rate Factor [0-51] (Lower is better quality)
QMAX=10                     # Maximum Quantization [1-31] (Lower is better quality)
FULLSCREEN="1024x768"          # Set your desktop resolution
#DISPLAY=:0.0                    # Set to record specific monitor 0.0 or 0.1?

OUTPUT="/home/yuppie/screencast.webm"
TMP="$HOME/out.mkv"
KEEP=false                      # Keep original mkv file after conversion [true|false]
FILENAME="/home/yuppie/desktop"
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo -e "Useage: $ sh screencast [OPTIONS]\n"
    echo "  -h|--help               Display this help"
    echo "  -m|--mode desktop       Set mode [\"desktop\"|\"window\"]"
    echo "  -s|--space 10           Set margin in window mode (px)"
    echo "  -t|--title 24           Set titlebar height in window mode (px)"
    echo "  -f|--fps 30             Set Frames Per Second [12-60]"
    echo "  -c|--crf 10             Set Constant Rate Factor [0-51] (Lower is better quality)"
    echo "  -q|--qmax 10            Set Maximum Quantization [1-31] (Lower is better quality)"
    echo "  -p|--preset ultrafast   Set preset (x264 --help for preset list)"
    echo "  -k|--keep false         Keep original mkv file after conversion [true|false]"
    echo "  -o|--output file.webm   Output webm file"
    echo -e "\n"; exit 0
fi

OPTS=`getopt -o m:s:t:o:f:c:p:q:k: --long mode:,space:,title:,output:,fps:,crf:,preset:,qmax:,keep: -- "$@"`
eval set -- "$OPTS"

ERROR=0

while true; do
    case "$1" in
        -m|--mode)   MODE="$2";   shift 2;;  -s|--space)  MARGIN="$2"; shift 2;;
        -o|--output) OUTPUT="$2"; shift 2;;  -p|--preset) PRESET="$2"; shift 2;;
        -f|--fps)    FPS="$2";    shift 2;;  -c|--crf)    CRF="$2";    shift 2;;
        -q|--qmax)   QMAX="$2";   shift 2;;  -k|--keep)   KEEP=$2;     shift 2;;
        -t|--title)  TITLEBAR="$2" shift 2;;
        --)          shift; break;;          *) echo "Internal error!"; exit 1
    esac
done

if [ "$MODE" = "window" ]; then
    WINFO=$(xwininfo)
    
    WINX=$(($(echo $WINFO|grep -Po 'Absolute upper-left X: \K[^ ]*')-$MARGIN))
    WINY=$(($(echo $WINFO|grep -Po 'Absolute upper-left Y: \K[^ ]*')-$MARGIN-$TITLEBAR))
    WINW=$(($(echo $WINFO|grep -Po 'Width: \K[^ ]*')+($MARGIN*2)))
    WINH=$(($(echo $WINFO|grep -Po 'Height: \K[^ ]*')+($MARGIN*2+$TITLEBAR)))

    sleep 2 # Wait before recording begin
    wnote.sh "Window is now being recorded. Stop by pressing Ctrl+Alt+X."

    # Record Window
    ffmpeg -f x11grab -s "$WINW"x"$WINH" -r $FPS -i $DISPLAY"+$WINX,$WINY" -c:v libx264 -preset $PRESET -crf $CRF "$TMP" #|| ERROR=1
else
    sleep 2 # Wait before recording begin
    wnote.sh "recording your desktop!" "stop with ctrl-alt-x"

    # Record Fullscreen
    ffmpeg -f x11grab -s $FULLSCREEN -r $FPS -i $DISPLAY -c:v libx264 -preset $PRESET -crf $CRF "$TMP" #|| ERROR=1
fi
wnote.sh "Desktop is no longer being recorded. Video is now being converted to webm."

#Create Filename

# Convert Video: mkv -> webm
ffmpeg -i "$TMP" -c:v libvpx -qmin 1 -qmax $QMAX -an -threads 4 -slices 8 -auto-alt-ref 1 -lag-in-frames 16 -pass 1 -f webm  /dev/null -y|| ERROR=1
ffmpeg -i "$TMP" -c:v libvpx -qmin 1 -qmax $QMAX -an -threads 4 -slices 8 -auto-alt-ref 1 -lag-in-frames 16 -pass 2  "$FILENAME".webm -y || ERROR=1
rm ffmpeg2pass*.log
if [[ -f "$TMP" && "$KEEP" = false ]]; then rm -f "$TMP"; fi

if [ "$ERROR" -eq 0 ]; then
    echo -e "\n\n\033[0;32mRecording and Converting has finished and"\
        "\"\033[0;34m$FILENAME\033[0;32m\" has been \033[1;32mSuccessfully created\033[0;32m.\033[0m\n\n";

    wnote.sh "Video was successfully converted to webm!"
    exit 0
else
    echo -e "\n\n\033[0;31mAn unexpected Error prevented the screen recorder to complete,"\
        "screencast was \033[1;31mNot created\033[0;31m.\033[0m\n\n";

    wnote.sh "An unexpected error prevented the video conversion to complete."
    exit 1
fi
