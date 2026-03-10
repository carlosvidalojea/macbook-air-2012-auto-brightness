# macbook-air-2012-auto-brightness for Linux
Auto-brightness Lightweight script for Linux Mint that activates the ambient light sensor on MacBook Air 5.2. Includes smooth transitions (fade) to avoid abrupt brightness jumps and optimizes battery consumption.

Auto-brightness script specifically calibrated for the **MacBook Air 5,2 (Mid-2012)** running Linux Mint or Ubuntu-based distributions.

Tested on MacBook Air 5,2 (Mid-2012) running Linux Mint 22.

## Key Features
- **Cinematic Fade:** Smooth, frame-by-frame brightness transitions (no sudden jumps).
- **Ambient Light Sensor (ALS) Integration:** Uses the native MacBook sensor via `iio-sensor-proxy`.
- **Battery Optimized:** Minimal CPU usage; only triggers when light conditions change.
- **Hardware Calibrated:** Precise Lux-to-Brightness mapping for the 13" Apple display.

## Installation

### 1. Install Dependencies:
```
sudo apt update && sudo apt install iio-sensor-proxy brightnessctl
```
### 2. Set Hardware Permissions:
To allow the script to change brightness without root privileges, create a Udev rule:
```
echo 'ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0", RUN+="/bin/chmod 666 /sys/class/backlight/acpi_video0/brightness"' | sudo tee /etc/udev/rules.d/backlight.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```
### 3. Setup the Script
Create the directory and save the auto_brightness.sh file into that folder: 
```
mkdir -p ~/.local/bin
mv ~/auto_brightness.sh ~/.local/bin/
```
Make it executable:
```
chmod +x ~/.local/bin/auto_brightness.sh
```
### 4. Run at Startup
Add the script to your Startup Applications:
Name: MacBook Auto Brightness
Command: /bin/bash /home/YOUR_USER/.local/bin/auto_brightness.sh
Delay: 30 seconds (recommended)
