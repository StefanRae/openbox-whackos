#!/bin/bash

weatherfile='/tmp/weather.xml'
wget -q 'https://data.buienradar.nl/1.0/feed/xml' -O $weatherfile

data=$(xmllint --format $weatherfile | grep -A 14 '"Maastricht"')

# Extract the temperature, wind speed, and wind direction
temp=$(echo "$data" | grep -oP 'temperatuurGC.*' | grep -oP '[0-9.]+')
# windsnelheid=$(echo "$data" | grep -oP 'windsnelheid.*' | grep -oP '[0-9.]+')
windrichting=$(echo "$data" | grep -oP '(?<=<windrichting>)[^<]+(?=</windrichting>)')
beschrijving=$(echo "$data" | grep -oP 'temperatuurGC.*' | grep -oP '[0-9.]+')

# Output them in the form temp|windsnelheid|windrichting
echo "$temp|$windrichting"
