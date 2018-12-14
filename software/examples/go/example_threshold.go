package main

import (
	"fmt"
	"tinkerforge/ambient_light_v2_bricklet"
	"tinkerforge/ipconnection"
)

const ADDR string = "localhost:4223"
const UID string = "XYZ" // Change XYZ to the UID of your Ambient Light Bricklet 2.0.

func main() {
	ipcon := ipconnection.New()
	defer ipcon.Close()
	al, _ := ambient_light_v2_bricklet.New(UID, &ipcon) // Create device object.

	ipcon.Connect(ADDR) // Connect to brickd.
	defer ipcon.Disconnect()
	// Don't use device before ipcon is connected.

	// Get threshold receivers with a debounce time of 10 seconds (10000ms).
	al.SetDebouncePeriod(10000)

	al.RegisterIlluminanceReachedCallback(func(illuminance uint32) {
		fmt.Printf("Illuminance: %d lx\n", float64(illuminance)/100.0)
		fmt.Println("Too bright, close the curtains!")
	})

	// Configure threshold for illuminance "greater than 500 lx".
	al.SetIlluminanceCallbackThreshold('>', 500*100, 0)

	fmt.Print("Press enter to exit.")
	fmt.Scanln()

}
