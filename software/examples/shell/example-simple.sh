#!/bin/sh
# connects to localhost:4223 by default, use --host and --port to change it

# change to your UID
uid=XYZ

# get current illuminance (unit is Lux/100)
tinkerforge call ambient-light-v2-bricklet $uid get-illuminance
