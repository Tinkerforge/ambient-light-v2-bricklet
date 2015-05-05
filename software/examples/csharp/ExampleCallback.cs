using Tinkerforge;

class Example
{
	private static string HOST = "localhost";
	private static int PORT = 4223;
	private static string UID = "XYZ"; // Change to your UID

	// Callback function for illuminance callback (parameter has unit Lux/100)
	static void IlluminanceCB(BrickletAmbientLightV2 sender, long illuminance)
	{
		System.Console.WriteLine("Illuminance: " + illuminance/100.0 + " Lux");
	}

	static void Main() 
	{
		IPConnection ipcon = new IPConnection(); // Create IP connection
		BrickletAmbientLightV2 al = new BrickletAmbientLightV2(UID, ipcon); // Create device object

		ipcon.Connect(HOST, PORT); // Connect to brickd
		// Don't use device before ipcon is connected

		// Set Period for illuminance callback to 1s (1000ms)
		// Note: The illuminance callback is only called every second if the 
		//       illuminance has changed since the last call!
		al.SetIlluminanceCallbackPeriod(1000);

		// Register illuminance callback to function IlluminanceCB
		al.Illuminance += IlluminanceCB;

		System.Console.WriteLine("Press enter to exit");
		System.Console.ReadLine();
		ipcon.Disconnect();
	}
}