#!/bin/bash

# Function to get the current workspace
get_current_workspace() {
    wmctrl -d | awk '$2 == "*" {print $1}'
}

# Function to get all windows on the current workspace
get_windows() {
    current_workspace=$(get_current_workspace)
    wmctrl -l | awk -v ws="$current_workspace" '$2 == ws {print $1}'
}

# Function to format window titles for lemonbar
format_windows() {
    echo -n "(box "
    for wid in $(get_windows); do
        title=$(xprop -id $wid WM_NAME | cut -d '"' -f 2)
        echo -n "(button :style \"background-color: #FFFFFF;\" :onclick \"bash -c 'xprop -id $wid _NET_WM_STATE | grep -q _NET_WM_STATE_HIDDEN && wmctrl -i -r $wid -b remove,hidden || wmctrl -i -r $wid -b add,hidden'\" (label :text '$title' :limit-width 20))"

    done
    echo ")"
}

# Main loop to update the taskbar
while :; do
    echo "$(format_windows)" > /tmp/taskbar.txt
    sleep 0.1
done
