#!/bin/sh

Music() {
    # Seperate Song and Artist
    RAW_MUSIC=$(cat /home/stefan/Scripts/current_mpd_song.txt)
    ARTIST=$(echo "$RAW_MUSIC" | cut -d '-' -f 1)
    SONG=$(echo "$RAW_MUSIC" | cut -d '-' -f 2-)

    # Format Song and Artist
    ARTIST=$(echo "$ARTIST" | sed 's/^ *//;s/ *$//')
    SONG=$(echo "$SONG" | sed 's/^ *//;s/ *$//')

    # Check if MPC is playing or paused

    if [ -z "$RAW_MUSIC" ]; then
        NOT_PLAYING="true"
    else
        NOT_PLAYING="false"
    fi

    PAUSED=$(echo "$RAW_MUSIC" | grep -q '\[paused\]' && echo "true" || echo "false")

    # Memory if Music is not playing
    MEM=$(free -h | awk '/^Mem/ {print "RAM: "$3 "/" $2}')

    # Display Music, Otherwise display Mem
    if [ "$NOT_PLAYING" = "true" ]; then
        echo -e "$MEM\n─────"
    elif [ "$PAUSED" = "true" ]; then
        echo "paused"
        echo -e "$SONG -\n[PAUSED]\n─────"
    else
        echo -e "$ARTIST -\n$SONG\n─────"
    fi
}

echo "$(Music)"

