#!/bin/sh
# Connects to localhost:4223 by default, use --host and --port to change this

uid=XYZ # Change XYZ to the UID of your Ambient Light Bricklet 2.0

# Handle incoming illuminance callbacks
tinkerforge dispatch ambient-light-v2-bricklet $uid illuminance &

# Set period for illuminance callback to 1s (1000ms)
# Note: The illuminance callback is only called every second
#       if the illuminance has changed since the last call!
tinkerforge call ambient-light-v2-bricklet $uid set-illuminance-callback-period 1000

echo "Press key to exit"; read dummy

kill -- -$$ # Stop callback dispatch in background
