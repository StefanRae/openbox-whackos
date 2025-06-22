#!/bin/bash
month=$(date +"%B")
day=$(date +"%A")
month_number=$(date +"%m")

# Capitalize the first letter of month and day
capitalized_month=$(echo "$month" | sed 's/.*/\u&/')
capitalized_day=$(echo "$day" | sed 's/.*/\u&/')

# Print the formatted date
echo "$month_number $capitalized_month $capitalized_day"
