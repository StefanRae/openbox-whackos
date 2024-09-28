#!/bin/bash

# weatherfile='/tmp/weather.xml'
# wget -q '' -O $weatherfile

# data=$(xmllint --format $weatherfile | grep -A 15 '"Maastricht"')\

# # echo $data

# # Extract the temperature, wind speed, and wind direction
# temp=$(echo "$data" | grep -oP 'temperatuurGC.*' | grep -oP '[0-9.]+')
# # windsnelheid=$(echo "$data" | grep -oP 'windsnelheid.*' | grep -oP '[0-9.]+')
# windrichting=$(echo "$data" | grep -oP '(?<=<windrichting>)[^<]+(?=</windrichting>)')
# beschrijving=$(echo "$data" | grep -oP 'temperatuurGC.*' | grep -oP '[0-9.]+')
# zin=$(echo "$data" | grep -oP 'zin="\K[^"]+')
# icon_url=$(echo "$data" | grep -oP '<icoonactueel[^>]*>\K[^<]+')

# output_file='/home/stefan/.config/eww/resources/weather_icon.png'
# wget -q "$icon_url" -O "$output_file"

# # Output them in the form temp|windsnelheid|windrichting
# echo "$temp|$windrichting|$zin"
