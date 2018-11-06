use std::{error::Error, io, thread};
use tinkerforge::{ambient_light_v2_bricklet::*, ipconnection::IpConnection};

const HOST: &str = "127.0.0.1";
const PORT: u16 = 4223;
const UID: &str = "XYZ"; // Change XYZ to the UID of your Ambient Light Bricklet 2.0

fn main() -> Result<(), Box<dyn Error>> {
    let ipcon = IpConnection::new(); // Create IP connection
    let ambient_light_v2_bricklet = AmbientLightV2Bricklet::new(UID, &ipcon); // Create device object

    ipcon.connect(HOST, PORT).recv()??; // Connect to brickd
                                        // Don't use device before ipcon is connected

    // Get threshold listeners with a debounce time of 10 seconds (10000ms)
    ambient_light_v2_bricklet.set_debounce_period(10000);

    //Create listener for illuminance reached events.
    let illuminance_reached_listener = ambient_light_v2_bricklet.get_illuminance_reached_receiver();
    // Spawn thread to handle received events. This thread ends when the ambient_light_v2_bricklet
    // is dropped, so there is no need for manual cleanup.
    thread::spawn(move || {
        for event in illuminance_reached_listener {
            println!("Illuminance: {}{}", event as f32 / 100.0, " lx");
            println!("Too bright, close the curtains!");
        }
    });

    // Configure threshold for illuminance "greater than 500 lx"
    ambient_light_v2_bricklet.set_illuminance_callback_threshold('>', 500 * 100, 0);

    println!("Press enter to exit.");
    let mut _input = String::new();
    io::stdin().read_line(&mut _input)?;
    ipcon.disconnect();
    Ok(())
}
