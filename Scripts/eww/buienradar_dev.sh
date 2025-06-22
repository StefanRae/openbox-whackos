#!/bin/bash

weatherfile='/tmp/weather.xml'
wget -q 'https://data.buienradar.nl/1.0/feed/xml' -O $weatherfile

data=$(xmllint --format $weatherfile | grep -A 15 '"Maastricht"')

# Extract the temperature, wind speed, wind direction, and other info
temp=$(echo "$data" | grep -oP 'temperatuurGC.*' | grep -oP '[0-9.]+')
windrichting=$(echo "$data" | grep -oP '(?<=<windrichting>)[^<]+(?=</windrichting>)')
beschrijving=$(echo "$data" | grep -oP 'temperatuurGC.*' | grep -oP '[0-9.]+')
zin=$(echo "$data" | grep -oP 'zin="\K[^"]+')
icon_url=$(echo "$data" | grep -oP '<icoonactueel[^>]*>\K[^<]+')

output_file='/home/stefan/.config/eww/resources/weather_icon.png'
wget -q "$icon_url" -O "$output_file"

# Write temp, windrichting, beschrijving, and zin each on a new line in /tmp/buienradar.txt
output_text="/tmp/buienradar.txt"
echo "$temp" > $output_text
echo "$windrichting" >> $output_text
echo "$beschrijving" >> $output_text
echo "$zin" >> $output_text
