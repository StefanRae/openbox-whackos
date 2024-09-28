#!/bin/bash

# Search for the window by name or part of the name
WINDOW_NAME=spotify_player

# Get the window ID based on the name
WIN_ID=$(wmctrl -lx | grep -i "$WINDOW_NAME" | awk '{print $1}')

# Get the current workspace
CURRENT_WS=$(wmctrl -d | grep '*' | awk '{print $1}')

# If window exists, check if it's minimized (iconified)
if [ -n "$WIN_ID" ]; then
    # Check if the window is minimized (iconified)
    IS_MINIMIZED=$(xprop -id "$WIN_ID" | grep "_NET_WM_STATE_HIDDEN")

    if [ -n "$IS_MINIMIZED" ]; then
        # Uniconify the window (restore it)
        wmctrl -ir "$WIN_ID" -b remove,hidden
        echo "Restored window '$WINDOW_NAME' from minimized state."
    fi

    # Move the window to the current workspace
    wmctrl -ir "$WIN_ID" -t "$CURRENT_WS"
    echo "Moved window '$WINDOW_NAME' to workspace $CURRENT_WS"

    # Bring the window to the front and give it focus
    wmctrl -ia "$WIN_ID"
    echo "Brought window '$WINDOW_NAME' to the front."
else
    echo "Window '$WINDOW_NAME' not found."
fi
