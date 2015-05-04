#!/bin/sh
# connects to localhost:4223 by default, use --host and --port to change it

# change to your UID
uid=XYZ

# get threshold callbacks with a debounce time of 10 seconds (10000ms)
tinkerforge call ambient-light-v2-bricklet $uid set-debounce-period 10000

# configure threshold for "greater than 200 Lux" (unit is Lux/100)
tinkerforge call ambient-light-v2-bricklet $uid set-illuminance-callback-threshold greater 20000 0

# handle incoming illuminance-reached callbacks (unit is Lux/100)
tinkerforge dispatch ambient-light-v2-bricklet $uid illuminance-reached\
 --execute "echo We have {illuminance} Lux/100. Too bright, close the curtains!"
