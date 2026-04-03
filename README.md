# macbook-air-2012-auto-brightness for Linux
Auto-brightness lightweight script for Linux Mint that activates the ambient light sensor on MacBook Air 5.2. Includes smooth transitions (fade) to avoid abrupt brightness jumps and optimizes battery consumption.

Auto-brightness script specifically calibrated for the **MacBook Air 5,2 (Mid-2012)** running Linux Mint or Ubuntu-based distributions.

Tested on MacBook Air 5,2 (Mid-2012) running Linux Mint 22.

## Key Features
- **Cinematic Fade:** Smooth, frame-by-frame brightness transitions for both display and keyboard (no sudden jumps).
- **Ambient Light Sensor (ALS) Integration:** Uses the native MacBook sensor via `iio-sensor-proxy`.
- **Keyboard Backlight Control:** Automatically adjusts keyboard backlight based on ambient light (off above 20 lux).
- **Battery Optimized:** Minimal CPU usage; only triggers when light conditions change.
- **Hardware Calibrated:** Precise Lux-to-Brightness mapping for the 13" Apple display.

## Lux Mapping

### Display
| Lux | Situation | Brightness |
|-----|-----------|------------|
| 0–1 | Pitch black | 5% |
| 2–3 | Very dim | 10% |
| 4–6 | Dim | 18% |
| 7–10 | Low light | 26% |
| 11–16 | Dark indoor | 36% |
| 17–24 | Normal indoor | 48% |
| 25–35 | Bright indoor | 60% |
| 36–60 | Near window / Daylight | 75% |
| 61–100 | Very bright | 88% |
| 100+ | Direct sunlight | 100% |

### Keyboard Backlight
| Lux | Situation | Backlight |
|-----|-----------|-----------|
| 0–3 | Pitch black | 20% |
| 4–7 | Very dim | 30% |
| 8–14 | Low light | 40% |
| 15–20 | Normal indoor | 50% |
| 20+ | Bright | Off |

## Installation

### 1. Install Dependencies
```bash
sudo apt update && sudo apt install iio-sensor-proxy brightnessctl
```

### 2. Set Display Brightness Permissions
To allow the script to change display brightness without root privileges, create a udev rule:
```bash
echo 'ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0", RUN+="/bin/chmod 666 /sys/class/backlight/acpi_video0/brightness"' | sudo tee /etc/udev/rules.d/backlight.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### 3. Set Keyboard Backlight Permissions
To allow the script to control keyboard backlight without root privileges, create a sudoers rule:
```bash
sudo visudo -f /etc/sudoers.d/kbd-backlight
```
Add this line (replace `your_user` with your username):
```bash
your_user ALL=(ALL) NOPASSWD: /usr/bin/tee "/sys/class/leds/smc::kbd_backlight/brightness"
```
Verify the rule is valid:
```bash
sudo visudo -c -f /etc/sudoers.d/kbd-backlight
```

### 4. Setup the Script
Create the directory and save the `auto_brightness.sh` (only screen auto-brightness script) or `auto_brightness_v2.sh` (screen and keyboard Backlight script) file into that folder:
```bash
mkdir -p ~/.local/bin
mv ~/auto_brightness.sh ~/.local/bin/
```
Make it executable:
```bash
chmod +x ~/.local/bin/auto_brightness.sh
```

### 5. Run at Startup
Add the script to your Startup Applications:

- **Name:** `MacBook Auto Brightness`
- **Command:** `/bin/bash /home/YOUR_USER/.local/bin/auto_brightness.sh`
- **Delay:** 30 seconds (recommended)
