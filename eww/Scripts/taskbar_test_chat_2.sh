#!/bin/bash

get_windows() {
    wmctrl -l | awk '$2 == 1 {print $1}'
}

format_windows() {
    echo -n "(box "
    for wid in $(get_windows); do
        title=$(xprop -id $wid WM_NAME | cut -d '"' -f 2)
        echo -n "(button (label :text '$title' :limit-width 20))"
    done
    echo ")"
}

while :; do
    echo "$(format_windows)" > /tmp/taskbar.txt
    sleep 0.1
done
