#!/bin/bash


get_spotify_info() {
    playerctl --player=spotify_player metadata --format '{{ artist }} - {{ title }}' 2>/dev/null
}

# Function to get the currently playing song for MPD
get_mpd_info() {
    mpc current 2>/dev/null
}

# Function to update the 'current_mpd_song.txt' file
update_file() {
    artist_title="$1"
    echo "$artist_title" > ~/Scripts/current_song.txt
}

# Main script
while true; do
    # Check if Spotify is playing
    if playerctl --player=spotify_player status 2>/dev/null | grep -q "Playing"; then
        song_info=$(get_spotify_info)
        update_file "$song_info"
    elif playerctl --player=spotify_player status 2>/dev/null | grep -q "Paused"; then
        song_info=$(get_spotify_info)
        update_file "$song_info | Paused"
    # Check if MPD is playing
    elif mpc status 2>/dev/null | grep -q "playing"; then
        song_info=$(get_mpd_info)
        update_file "$song_info"
    else
        song_info=""
        update_file "$song_info"
    fi

    # Sleep for a short duration before checking again
    sleep 5
done
