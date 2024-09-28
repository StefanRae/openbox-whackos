#!/bin/bash

# Get current position in seconds
position=$(playerctl position)

# Get total track length in seconds (convert from microseconds to seconds)
duration=$(playerctl metadata mpris:length)
duration=$(($duration / 1000000))

# Calculate progress percentage
if [ $duration -gt 0 ]; then
  progress=$(echo "($position / $duration) * 100" | bc -l)
  printf $progress
else
  echo "0"
fi
