#!/bin/bash

# --------------- configurable paths -----------------
COVER_PATH="/tmp/spotify_album_cover.jpg"
TEMP_COVER_PATH="/tmp/spotify_album_cover_tmp.jpg"

ARROW_PATH="/tmp/album_arrow.svg"
TEMP_ARROW_PATH="/tmp/album_arrow_tmp.svg"

# Location of the static arrow template that still contains #DDDDDD.
# Copy‑paste the SVG you sent into this file once, or keep it beside this script.
ARROW_TEMPLATE="/home/stefan/.config/eww/resources/icons/album_arrow_smooth_colour.svg"
# ----------------------------------------------------

LAST_URL=""

# ---------- helper: extract dominant colour ----------
extract_dominant_colour () {
    local img="$1"

    # Get width and height
    read -r w h < <(magick identify -format "%w %h" "$img")

    # Calculate 5% height and 15% width
    local crop_h=$(( h * 5 / 100 ))
    local crop_w=$(( w * 15 / 100 ))

    # Offsets to start cropping from bottom-right corner
    local offset_x=$(( w - crop_w ))
    local offset_y=$(( h - crop_h ))

    # Extract RGB values from cropped region
    read -r r g b < <(magick "$img" \
        -crop "${crop_w}x${crop_h}+${offset_x}+${offset_y}" +repage \
        -resize 1x1\! \
        -format "%[fx:int(255*r)] %[fx:int(255*g)] %[fx:int(255*b)]" info:)

    # Convert to hex
    printf "#%02x%02x%02x\n" "$r" "$g" "$b"
}
# ----------------------------------------------------

while true; do
    CURRENT_URL=$(playerctl --player=spotify_player metadata mpris:artUrl 2>/dev/null)

    if [[ -n $CURRENT_URL && $CURRENT_URL != "$LAST_URL" ]]; then
        # --- 1. download cover -------------------------------------------------
        curl -s -o "$TEMP_COVER_PATH" "$CURRENT_URL" &&
        mv "$TEMP_COVER_PATH" "$COVER_PATH"

        # --- 2. pick dominant colour ------------------------------------------
        COLOUR=$(extract_dominant_colour "$COVER_PATH")

        # --- 3. build arrow SVG -----------------------------------------------
        # replace all occurrences of #DDDDDD with the new colour
        sed "s/#DDDDDD/${COLOUR}/g" "$ARROW_TEMPLATE" > "$TEMP_ARROW_PATH" &&
        mv "$TEMP_ARROW_PATH" "$ARROW_PATH"

        # --- 4. update Eww -----------------------------------------------------
        eww update bottom_album_colour="$COLOUR"
        eww update album_arrow="$ARROW_PATH"
#         eww update album_cover="background-image: linear-gradient(0deg, rgba(0,0,0,0.74), rgba(0,0,0,0)), url(\"$COVER_PATH\"); \
# background-size: cover; background-position: center; margin: 9px; box-shadow: inset 0 5px 10px rgb(0,0,0);"
    # eww update album_cover="background-image: url(\"$COVER_PATH\"); \
    # background-size: cover; background-position: center; margin: 9px;"
    # eww update album_cover="album_smooth"
    eww update album_cover="background-image: url(\"$COVER_PATH\");"

        LAST_URL="$CURRENT_URL"
    fi

    sleep 5
done
