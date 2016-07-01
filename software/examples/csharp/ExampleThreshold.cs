using System;
using Tinkerforge;

class Example
{
	private static string HOST = "localhost";
	private static int PORT = 4223;
	private static string UID = "XYZ"; // Change XYZ to the UID of your Ambient Light Bricklet 2.0

	// Callback function for illuminance reached callback (parameter has unit Lux/100)
	static void IlluminanceReachedCB(BrickletAmbientLightV2 sender, long illuminance)
	{
		Console.WriteLine("Illuminance: " + illuminance/100.0 + " Lux");
		Console.WriteLine("Too bright, close the curtains!");
	}

	static void Main()
	{
		IPConnection ipcon = new IPConnection(); // Create IP connection
		BrickletAmbientLightV2 al = new BrickletAmbientLightV2(UID, ipcon); // Create device object

		ipcon.Connect(HOST, PORT); // Connect to brickd
		// Don't use device before ipcon is connected

		// Get threshold callbacks with a debounce time of 10 seconds (10000ms)
		al.SetDebouncePeriod(10000);

		// Register illuminance reached callback to function IlluminanceReachedCB
		al.IlluminanceReached += IlluminanceReachedCB;

		// Configure threshold for illuminance "greater than 500 Lux" (unit is Lux/100)
		al.SetIlluminanceCallbackThreshold('>', 500*100, 0);

		Console.WriteLine("Press enter to exit");
		Console.ReadLine();
		ipcon.Disconnect();
	}
}
