#!/bin/bash

# Path to the SVG file
SVG_PATH="/home/stefan/Scripts/eww/gradient.svg"

# Function to generate the SVG with the current time
generate_svg() {
  # Get the current time in the desired format (HH.MM)
  CURRENT_TIME=$(date '+%H.%M')

  # Create the SVG content with the current time
  cat << EOF > $SVG_PATH
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="100">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:rgb(255,126,95);stop-opacity:1" />
      <stop offset="100%" style="stop-color:rgb(254,180,123);stop-opacity:1" />
    </linearGradient>
  </defs>
  <text x="20" y="50" font-family="'San Francisco Pro Display', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif" font-size="45" fill="url(#grad1)">
    $CURRENT_TIME
  </text>
</svg>
EOF
}

# Initial SVG generation
generate_svg

# Update the SVG every minute
while true; do
  generate_svg
  sleep 1  # Wait for 1 minute before updating again
done
