#!/bin/bash

# Configuration
COVER_PATH="/tmp/spotify_album_cover.jpg"
COVER_BLURRED_PATH="/tmp/spotify_album_cover_blurred.jpg"
TEMP_COVER_PATH="/tmp/spotify_album_cover_tmp.jpg"
TEMP_BLURRED_PATH="/tmp/spotify_album_cover_blurred_tmp.jpg"
SONG_FILE="$HOME/Scripts/current_mpd_song.txt"
OUTPUT_FILE="$HOME/Scripts/music_status.json"
CACHE_FILE="/tmp/music_tracker_cache.json"

# Function to get Spotify info
get_spotify_info() {
    playerctl --player=spotify_player metadata --format '{{ artist }} - {{ title }}' 2>/dev/null
}

# Function to get playback status
get_status() {
    playerctl --player=spotify_player status 2>/dev/null
}

# Function to get position and duration
get_progress() {
    local position duration progress position_seconds duration_seconds
    position=$(playerctl --player=spotify_player position 2>/dev/null)
    duration=$(playerctl --player=spotify_player metadata mpris:length 2>/dev/null)
    
    if [[ -n "$position" && -n "$duration" && "$duration" -gt 0 ]]; then
        duration_seconds=$((duration / 1000000))
        position_seconds=$(echo "$position" | cut -d. -f1)
        
        if [[ "$duration_seconds" -gt 0 ]]; then
            progress=$(echo "scale=2; ($position / $duration_seconds) * 100" | bc -l 2>/dev/null)
            echo "{\"percent\": $progress, \"position\": $position_seconds, \"duration\": $duration_seconds}"
        else
            echo "{\"percent\": 0, \"position\": 0, \"duration\": 0}"
        fi
    else
        echo "{\"percent\": 0, \"position\": 0, \"duration\": 0}"
    fi
}

# Function to get album art URL
get_album_art_url() {
    playerctl --player=spotify_player metadata mpris:artUrl 2>/dev/null
}

# Function to download album cover and create blurred version
update_album_cover() {
    local url="$1"
    local last_url=""
    
    # Read last URL from cache if exists
    if [[ -f "$CACHE_FILE" ]]; then
        last_url=$(jq -r '.last_album_url // ""' "$CACHE_FILE" 2>/dev/null || echo "")
    fi
    
    if [[ -n "$url" && "$url" != "$last_url" ]]; then
        if curl -s -o "$TEMP_COVER_PATH" "$url"; then
            # Move original to final location
            mv "$TEMP_COVER_PATH" "$COVER_PATH"
            
            # Create blurred version using ImageMagick
            if command -v magick >/dev/null 2>&1; then
                magick "$COVER_PATH" -blur 0x8 "$COVER_BLURRED_PATH"
            elif command -v convert >/dev/null 2>&1; then
                convert "$COVER_PATH" -blur 0x8 "$COVER_BLURRED_PATH"
            else
                echo "Warning: ImageMagick not found, blur effect disabled" >&2
                cp "$COVER_PATH" "$COVER_BLURRED_PATH"
            fi
            
            # Update cache with new URL
            echo "{\"last_album_url\": \"$url\", \"updated_at\": \"$(date -u +%s)\"}" > "$CACHE_FILE"
            return 0
        fi
    fi
    return 1
}

# Function to switch between normal and blurred cover based on playback status
update_cover_for_status() {
    local status="$1"
    local cache_status=""
    
    # Read last status from cache
    if [[ -f "$CACHE_FILE" ]]; then
        cache_status=$(jq -r '.last_status // ""' "$CACHE_FILE" 2>/dev/null || echo "")
    fi
    
    # Only update if status changed and both cover files exist
    if [[ "$status" != "$cache_status" && -f "$COVER_PATH" && -f "$COVER_BLURRED_PATH" ]]; then
        case "$status" in
            "Playing")
                # Use normal cover for playing
                if [[ -f "$COVER_BLURRED_PATH" ]]; then
                    cp "$COVER_PATH" "$TEMP_COVER_PATH"
                    mv "$TEMP_COVER_PATH" "$COVER_PATH"
                fi
                ;;
            "Paused")
                # Use blurred cover for paused
                if [[ -f "$COVER_BLURRED_PATH" ]]; then
                    cp "$COVER_BLURRED_PATH" "$TEMP_COVER_PATH"
                    mv "$TEMP_COVER_PATH" "$COVER_PATH"
                fi
                ;;
        esac
        
        # Update status in cache
        local current_cache="{}"
        if [[ -f "$CACHE_FILE" ]]; then
            current_cache=$(cat "$CACHE_FILE")
        fi
        echo "$current_cache" | jq --arg status "$status" '. + {"last_status": $status}' > "$CACHE_FILE"
        
        return 0
    fi
    return 1
}

# Function to create JSON output
create_json_output() {
    local song_info="$1"
    local status="$2"
    local progress_json="$3"
    local album_url="$4"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Escape JSON strings properly
    song_info=$(echo "$song_info" | jq -R -s '.')
    status=$(echo "$status" | jq -R -s '.')
    album_url=$(echo "$album_url" | jq -R -s '.')
    
    # Remove trailing newlines from jq output
    song_info=${song_info%$'\n'}
    status=${status%$'\n'}
    album_url=${album_url%$'\n'}
    
    cat << EOF
{
  "timestamp": "$timestamp",
  "player": "spotify_player",
  "song": $song_info,
  "status": $status,
  "progress": $progress_json,
  "album_art_url": $album_url,
  "album_cover_path": "$COVER_PATH",
  "album_cover_blurred_path": "$COVER_BLURRED_PATH",
  "is_playing": $([ "$(echo "$status" | tr -d '"')" == "Playing" ] && echo "true" || echo "false")
}
EOF
}

# Main function for single execution (suitable for defpoll)
get_music_status() {
    local song_info=""
    local status=""
    local progress_json='{"percent": 0, "position": 0, "duration": 0}'
    local album_url=""
    
    # Check Spotify
    spotify_status=$(get_status)
    if [[ -n "$spotify_status" ]]; then
        case "$spotify_status" in
            "Playing"|"Paused")
                song_info=$(get_spotify_info)
                status="$spotify_status"
                progress_json=$(get_progress)
                album_url=$(get_album_art_url)
                
                # Update cover blur state based on status
                update_cover_for_status "$status"
                ;;
            *)
                status="$spotify_status"
                ;;
        esac
    fi
    
    # Create and output JSON
    create_json_output "$song_info" "$status" "$progress_json" "$album_url"
}

# Function to get only progress (for fast polling)
get_progress_only() {
    get_progress
}

# Function to get basic status (for medium polling)
get_basic_status() {
    local song_info=""
    local status=""
    
    spotify_status=$(get_status)
    if [[ -n "$spotify_status" ]]; then
        case "$spotify_status" in
            "Playing"|"Paused")
                song_info=$(get_spotify_info)
                status="$spotify_status"
                
                # Update cover blur state based on status
                update_cover_for_status "$status"
                ;;
        esac
    fi
    
    # Output minimal JSON
    song_info=$(echo "$song_info" | jq -R -s '.' | tr -d '\n')
    status=$(echo "$status" | jq -R -s '.' | tr -d '\n')
    
    echo "{\"song\": $song_info, \"status\": $status, \"player\": \"spotify_player\", \"is_playing\": $([ "$(echo "$status" | tr -d '"')" == "Playing" ] && echo "true" || echo "false")}"
}

# Background daemon for album art updates (slow polling)
album_daemon() {
    echo "Starting album art daemon..."
    while true; do
        album_url=$(get_album_art_url)
        if [[ -n "$album_url" ]]; then
            if update_album_cover "$album_url"; then
                echo "$(date): Album cover updated (normal and blurred versions created)"
            fi
        fi
        
        # Also check if we need to update blur state
        current_status=$(get_status)
        if update_cover_for_status "$current_status"; then
            echo "$(date): Cover blur state updated for status: $current_status"
        fi
        
        sleep 10  # Check every 10 seconds
    done
}

# Legacy compatibility function
update_legacy_files() {
    while true; do
        local json_output=$(get_basic_status)
        local song=$(echo "$json_output" | jq -r '.song')
        local status=$(echo "$json_output" | jq -r '.status')
        
        # Update legacy text file
        mkdir -p "$(dirname "$SONG_FILE")"
        if [[ "$status" == "Paused" && -n "$song" ]]; then
            echo "$song | Paused" > "$SONG_FILE"
        else
            echo "$song" > "$SONG_FILE"
        fi
        
        # Update JSON file
        mkdir -p "$(dirname "$OUTPUT_FILE")"
        get_music_status > "$OUTPUT_FILE"
        
        sleep 5
    done
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    command -v playerctl >/dev/null 2>&1 || missing_deps+=("playerctl")
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v bc >/dev/null 2>&1 || missing_deps+=("bc")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    
    if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
        echo "Warning: ImageMagick not found. Blur effects will be disabled."
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Error: Missing dependencies: ${missing_deps[*]}"
        echo "Please install the missing packages and try again."
        exit 1
    fi
}

# Handle different command line arguments
case "${1:-status}" in
    "progress")
        # For fast polling (every 500ms-1s) - just progress
        get_progress_only
        ;;
    "basic")
        # For medium polling (every 2-3s) - song and status
        get_basic_status
        ;;
    "full"|"status")
        # For slow polling (every 5s) - full status
        get_music_status
        ;;
    "daemon")
        # Run as background daemon with album art updates
        check_dependencies
        trap 'echo "Stopping daemon..."; exit 0' SIGINT SIGTERM
        album_daemon &
        ALBUM_PID=$!
        update_legacy_files &
        LEGACY_PID=$!
        wait
        ;;
    "album-daemon")
        # Just the album art daemon
        check_dependencies
        trap 'echo "Stopping album daemon..."; exit 0' SIGINT SIGTERM
        album_daemon
        ;;
    *)
        echo "Usage: $0 [progress|basic|full|daemon|album-daemon]"
        echo "  progress      - Get only progress info (fast polling)"
        echo "  basic         - Get song and status (medium polling)"
        echo "  full          - Get complete status (default, slow polling)"
        echo "  daemon        - Run background daemon for legacy compatibility"
        echo "  album-daemon  - Run only album art background daemon"
        echo ""
        echo "Features:"
        echo "  - Album covers blur automatically when music is paused"
        echo "  - Efficient blur switching using pre-generated versions"
        echo "  - No MPD integration (Spotify only)"
        exit 1
        ;;
esac