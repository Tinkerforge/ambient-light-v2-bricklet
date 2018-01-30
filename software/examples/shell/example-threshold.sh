#!/bin/sh
# Connects to localhost:4223 by default, use --host and --port to change this

uid=XYZ # Change XYZ to the UID of your Ambient Light Bricklet 2.0

# Get threshold callbacks with a debounce time of 10 seconds (10000ms)
tinkerforge call ambient-light-v2-bricklet $uid set-debounce-period 10000

# Handle incoming illuminance reached callbacks
tinkerforge dispatch ambient-light-v2-bricklet $uid illuminance-reached\
 --execute "echo Illuminance: {illuminance}/100 lx. Too bright, close the curtains!" &

# Configure threshold for illuminance "greater than 500 lx"
tinkerforge call ambient-light-v2-bricklet $uid set-illuminance-callback-threshold threshold-option-greater 50000 0

echo "Press key to exit"; read dummy

kill -- -$$ # Stop callback dispatch in background
