#!/bin/bash

# Get the art URL using playerctl
art_url=$(playerctl --player=spotify_player metadata mpris:artUrl)

# Define the output path
output_path="/tmp/spotify_album_cover.jpg"

# Download the image to /tmp
curl -o "$output_path" "$art_url"

# You can now use this path in your eww widget or any other application
echo "Album cover downloaded to $output_path"
