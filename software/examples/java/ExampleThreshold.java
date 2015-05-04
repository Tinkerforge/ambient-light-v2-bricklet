import com.tinkerforge.BrickletAmbientLightV2;
import com.tinkerforge.IPConnection;

public class ExampleThreshold {
	private static final String HOST = "localhost";
	private static final int PORT = 4223;
	private static final String UID = "XYZ"; // Change to your UID

	// Note: To make the example code cleaner we do not handle exceptions. Exceptions you
	//       might normally want to catch are described in the documentation
	public static void main(String args[]) throws Exception {
		IPConnection ipcon = new IPConnection(); // Create IP connection
		BrickletAmbientLightV2 al = new BrickletAmbientLightV2(UID, ipcon); // Create device object

		ipcon.connect(HOST, PORT); // Connect to brickd
		// Don't use device before ipcon is connected

		// Get threshold callbacks with a debounce time of 10 seconds (10000ms)
		al.setDebouncePeriod(10000);

		// Configure threshold for "greater than 200 Lux" (unit is Lux/100)
		al.setIlluminanceCallbackThreshold('>', 200*100, 0);

		// Add and implement illuminance reached listener 
		// (called if illuminance is greater than 200 lux)
		al.addIlluminanceReachedListener(new BrickletAmbientLightV2.IlluminanceReachedListener() {
			public void illuminanceReached(long illuminance) {
				System.out.println("We have: " + illuminance/100.0 + " Lux.");
				System.out.println("Too bright, close the curtains!");
			}
		});

		System.out.println("Press key to exit"); System.in.read();
		ipcon.disconnect();
	}
}
