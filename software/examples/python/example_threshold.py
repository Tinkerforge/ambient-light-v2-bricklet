#!/usr/bin/env python
# -*- coding: utf-8 -*-

HOST = "localhost"
PORT = 4223
UID = "XYZ" # Change to your UID

from tinkerforge.ip_connection import IPConnection
from tinkerforge.bricklet_ambient_light_v2 import BrickletAmbientLightV2

# Callback function for illuminance greater than 1000 Lux (parameter has unit Lux/100)
def cb_illuminance_reached(illuminance):
    print('Illuminance: ' + str(illuminance/100.0) + ' Lux')
    print('Too bright, close the curtains!')

if __name__ == "__main__":
    ipcon = IPConnection() # Create IP connection
    al = BrickletAmbientLightV2(UID, ipcon) # Create device object

    ipcon.connect(HOST, PORT) # Connect to brickd
    # Don't use device before ipcon is connected

    # Get threshold callbacks with a debounce time of 10 seconds (10000ms)
    al.set_debounce_period(10000)

    # Register threshold reached callback to function cb_illuminance_reached
    al.register_callback(al.CALLBACK_ILLUMINANCE_REACHED, cb_illuminance_reached)

    # Configure threshold for "greater than 1000 Lux" (unit is Lux/100)
    al.set_illuminance_callback_threshold('>', 1000*100, 0)

    raw_input('Press key to exit\n') # Use input() in Python 3
    ipcon.disconnect()
