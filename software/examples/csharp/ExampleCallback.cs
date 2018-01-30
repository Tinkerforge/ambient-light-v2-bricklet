using System;
using Tinkerforge;

class Example
{
	private static string HOST = "localhost";
	private static int PORT = 4223;
	private static string UID = "XYZ"; // Change XYZ to the UID of your Ambient Light Bricklet 2.0

	// Callback function for illuminance callback
	static void IlluminanceCB(BrickletAmbientLightV2 sender, long illuminance)
	{
		Console.WriteLine("Illuminance: " + illuminance/100.0 + " lx");
	}

	static void Main()
	{
		IPConnection ipcon = new IPConnection(); // Create IP connection
		BrickletAmbientLightV2 al = new BrickletAmbientLightV2(UID, ipcon); // Create device object

		ipcon.Connect(HOST, PORT); // Connect to brickd
		// Don't use device before ipcon is connected

		// Register illuminance callback to function IlluminanceCB
		al.IlluminanceCallback += IlluminanceCB;

		// Set period for illuminance callback to 1s (1000ms)
		// Note: The illuminance callback is only called every second
		//       if the illuminance has changed since the last call!
		al.SetIlluminanceCallbackPeriod(1000);

		Console.WriteLine("Press enter to exit");
		Console.ReadLine();
		ipcon.Disconnect();
	}
}
