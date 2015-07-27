using Tinkerforge;

class Example
{
	private static string HOST = "localhost";
	private static int PORT = 4223;
	private static string UID = "XYZ"; // Change to your UID

	// Callback function for illuminance greater than 1000 Lux (parameter has unit Lux/100)
	static void IlluminanceReachedCB(BrickletAmbientLightV2 sender, long illuminance)
	{
		System.Console.WriteLine("Illuminance: " + illuminance/100.0 + " Lux");
		System.Console.WriteLine("Too bright, close the curtains!");
	}

	static void Main()
	{
		IPConnection ipcon = new IPConnection(); // Create IP connection
		BrickletAmbientLightV2 al = new BrickletAmbientLightV2(UID, ipcon); // Create device object

		ipcon.Connect(HOST, PORT); // Connect to brickd
		// Don't use device before ipcon is connected

		// Get threshold callbacks with a debounce time of 10 seconds (10000ms)
		al.SetDebouncePeriod(10000);

		// Register threshold reached callback to function IlluminanceReachedCB
		al.IlluminanceReached += IlluminanceReachedCB;

		// Configure threshold for "greater than 1000 Lux" (unit is Lux/100)
		al.SetIlluminanceCallbackThreshold('>', 1000*100, 0);

		System.Console.WriteLine("Press enter to exit");
		System.Console.ReadLine();
		ipcon.Disconnect();
	}
}
