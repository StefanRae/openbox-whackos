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

# Function to check if a window is minimized (iconified)
is_minimized() {
    xprop -id "$1" _NET_WM_STATE | grep -q _NET_WM_STATE_HIDDEN
}

# Function to check if a window is active
is_active() {
    active_window=$(xprop -root _NET_ACTIVE_WINDOW | awk -F' ' '{print $5}')
    [ "$1" = "$active_window" ]
}

# Function to format window titles for lemonbar
format_windows() {
    echo -n "(box "
    for wid in $(get_windows); do
        title=$(xprop -id $wid WM_NAME | cut -d '"' -f 2)

        if is_minimized "$wid"; then
            # Minimized windows will have black background styling
            button_class="taskbar_inactive"
            text_class="taskbar_text_inactive"
        elif is_active "$wid"; then
            # Active window will have white background styling
            button_class="taskbar_active"
            text_class="taskbar_text_active"
        else
            # Default styling for non-active, non-minimized windows
            button_class="taskbar_active"
            text_class="taskbar_text_active"
        fi

        # Werkt, zonder venster naar voren duwen
        # echo -n "(button :class '$button_class' :onclick \"bash -c 'xprop -id $wid _NET_WM_STATE | grep -q _NET_WM_STATE_HIDDEN && wmctrl -i -r $wid -b remove,hidden || wmctrl -i -r $wid -b add,hidden'\" (label :text '$title' :class '$text_class' :limit-width 20))"

        # Huidige script
        echo -n "(button :class '$button_class' :onclick \"bash -c 'if xprop -id $wid _NET_WM_STATE | grep -q _NET_WM_STATE_HIDDEN; then wmctrl -i -r $wid -b remove,hidden; wmctrl -i -a $wid; else wmctrl -i -r $wid -b add,hidden; fi'\" (label :text '$title' :class '$text_class' :limit-width 20))"

        # Geen idee
        # echo -n "(button :class '$button_class' :onclick \"bash -c 'xprop -id $wid _NET_WM_STATE | grep -q _NET_WM_STATE_HIDDEN && wmctrl -i -r $wid -b remove,hidden || wmctrl -i -r $wid -b add,hidden; wmctrl -i -a $wid''\" (label :text '$title' :class '$text_class' :limit-width 20))"
    done
    echo ")"
}

# Main loop to update the taskbar
while :; do
    # echo "$(format_windows)" > /tmp/taskbar.txt
    format_windows > /tmp/taskbar.txt.new && mv /tmp/taskbar.txt.new /tmp/taskbar.txt
    sleep 0.1
done
