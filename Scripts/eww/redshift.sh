#!/bin/bash

SLIDER_VALUE=$1

if [ "$SLIDER_VALUE" -lt 0 ]; then SLIDER_VALUE=0; fi
if [ "$SLIDER_VALUE" -gt 100 ]; then SLIDER_VALUE=100; fi

if [ "$SLIDER_VALUE" -eq 0 ]; then
    redshift -x
else
    TEMP=$(( 6500 - ( (6500 - 4500) * SLIDER_VALUE / 100 ) ))
    redshift -P -O $TEMP
fi
