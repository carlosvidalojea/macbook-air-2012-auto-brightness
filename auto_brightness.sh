#!/bin/bash
# =================================================================
# MacBook Air 2012 (5,2) Auto-Brightness Script
# Optimization: Ultra-Lazy Fade (Cinematic Transition)
# Requirements: iio-sensor-proxy, brightnessctl
# =================================================================

# 1. Get initial display brightness
ACTUAL=$(brightnessctl -d acpi_video0 -m | cut -d, -f4 | tr -d '%')

# 2. Monitor Ambient Light Sensor (ALS)
monitor-sensor | while read -r line; do
    if [[ "$line" == *"Light changed"* ]]; then
        # Extract Lux value (handles Apple/Mint decimal format)
        LUX=$(echo "$line" | grep -oP '\d+(?=,)' || echo "$line" | grep -oP '\d+' | head -1)
        [[ -z "$LUX" ]] && continue

        # 3. Progressive Scale (Calibrated for MacBook Air 5,2)
        if [ "$LUX" -le 1 ];   then TARGET=5;   # Pitch black
        elif [ "$LUX" -le 3 ];   then TARGET=10;  # Very dim
        elif [ "$LUX" -le 6 ];   then TARGET=18;  # Dim
        elif [ "$LUX" -le 10 ];  then TARGET=26;  # Low light
        elif [ "$LUX" -le 16 ];  then TARGET=36;  # Dark indoor
        elif [ "$LUX" -le 24 ];  then TARGET=48;  # NORMAL INDOOR (Sweet spot)
        elif [ "$LUX" -le 35 ];  then TARGET=60;  # Bright indoor
        elif [ "$LUX" -le 60 ];  then TARGET=75;  # Near window / Daylight
        elif [ "$LUX" -le 100 ]; then TARGET=88;  # Very bright
        else TARGET=100; fi                       # Direct sunlight

        # 4. Smooth Transition Logic (Fade)
        if [ "$TARGET" -ne "$ACTUAL" ]; then
            echo "Light: $LUX lux -> Target: $TARGET% (Current: $ACTUAL%)"
            
            # FADE UP: Smooth (0.08s per 1% step)
            while [ "$ACTUAL" -lt "$TARGET" ]; do
                ((ACTUAL++))
                brightnessctl -d acpi_video0 s ${ACTUAL}% > /dev/null
                sleep 0.08
            done
            
            # FADE DOWN: Cinematic/Natural (0.12s per 1% step)
            while [ "$ACTUAL" -gt "$TARGET" ]; do
                ((ACTUAL--))
                brightnessctl -d acpi_video0 s ${ACTUAL}% > /dev/null
                sleep 0.12
            done
        fi
    fi
done
