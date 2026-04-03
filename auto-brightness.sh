#!/bin/bash
# =================================================================
# MacBook Air 2012 (5,2) Auto-Brightness Script
# Optimization: Ultra-Lazy Fade (Cinematic Transition)
# Requirements: iio-sensor-proxy, brightnessctl
# =================================================================

# Keyboard backlight path
KBD_PATH="/sys/class/leds/smc::kbd_backlight/brightness"
KBD_MAX=$(cat /sys/class/leds/smc::kbd_backlight/max_brightness)

# 1. Get initial display brightness
ACTUAL=$(brightnessctl -d acpi_video0 -m | cut -d, -f4 | tr -d '%')
KBD_ACTUAL=0

# Function: calculate absolute keyboard value from percentage
kbd_value() {
    echo $(( KBD_MAX * $1 / 100 ))
}

# 2. Monitor Ambient Light Sensor (ALS)
monitor-sensor | while read -r line; do
    if [[ "$line" == *"Light changed"* ]]; then
        # Extract Lux value (handles Apple/Mint decimal format)
        LUX=$(echo "$line" | grep -oP '\d+(?=,)' || echo "$line" | grep -oP '\d+' | head -1)
        [[ -z "$LUX" ]] && continue

        # 3. Progressive Scale - Display (Calibrated for MacBook Air 5,2)
        if [ "$LUX" -le 1 ];     then TARGET=5;    # Pitch black
        elif [ "$LUX" -le 3 ];   then TARGET=10;   # Very dim
        elif [ "$LUX" -le 6 ];   then TARGET=18;   # Dim
        elif [ "$LUX" -le 10 ];  then TARGET=26;   # Low light
        elif [ "$LUX" -le 16 ];  then TARGET=36;   # Dark indoor
        elif [ "$LUX" -le 24 ];  then TARGET=48;   # Normal indoor (sweet spot)
        elif [ "$LUX" -le 35 ];  then TARGET=60;   # Bright indoor
        elif [ "$LUX" -le 60 ];  then TARGET=75;   # Near window / Daylight
        elif [ "$LUX" -le 100 ]; then TARGET=88;   # Very bright
        else TARGET=100; fi                         # Direct sunlight

        # 4. Progressive Scale - Keyboard backlight
        if [ "$LUX" -le 3 ];    then KBD_TARGET=$(kbd_value 20);   # Pitch black: 20%
        elif [ "$LUX" -le 7 ];  then KBD_TARGET=$(kbd_value 30);   # Very dim: 30%
        elif [ "$LUX" -le 14 ]; then KBD_TARGET=$(kbd_value 40);   # Low light: 40%
        elif [ "$LUX" -le 20 ]; then KBD_TARGET=$(kbd_value 50);   # Normal indoor: 50%
        else KBD_TARGET=0; fi                                       # Bright: off

        # 5. Keyboard backlight fade (background to avoid blocking display fade)
        if [ "$KBD_TARGET" -ne "$KBD_ACTUAL" ]; then
            echo "Light: $LUX lux -> Keyboard: $KBD_TARGET/$KBD_MAX"
            (
                _KBD_FROM=$KBD_ACTUAL
                _KBD_TO=$KBD_TARGET
                if [ "$_KBD_TO" -gt "$_KBD_FROM" ]; then
                    while [ "$_KBD_FROM" -lt "$_KBD_TO" ]; do
                        ((_KBD_FROM++))
                        echo "$_KBD_FROM" | sudo tee "$KBD_PATH" > /dev/null
                        sleep 0.02
                    done
                else
                    while [ "$_KBD_FROM" -gt "$_KBD_TO" ]; do
                        ((_KBD_FROM--))
                        echo "$_KBD_FROM" | sudo tee "$KBD_PATH" > /dev/null
                        sleep 0.02
                    done
                fi
            ) &
            KBD_ACTUAL=$KBD_TARGET
        fi

        # 6. Display brightness fade
        if [ "$TARGET" -ne "$ACTUAL" ]; then
            echo "Light: $LUX lux -> Display: $TARGET% (Current: $ACTUAL%)"

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