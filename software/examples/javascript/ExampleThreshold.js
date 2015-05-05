var Tinkerforge = require('tinkerforge');

var HOST = 'localhost';
var PORT = 4223;
var UID = 'XYZ'; // Change to your UID

var ipcon = new Tinkerforge.IPConnection(); // Create IP connection
var al = new Tinkerforge.BrickletAmbientLightV2(UID, ipcon); // Create device object

ipcon.connect(HOST, PORT,
    function(error) {
        console.log('Error: '+error);
    }
); // Connect to brickd
// Don't use device before ipcon is connected

ipcon.on(Tinkerforge.IPConnection.CALLBACK_CONNECTED,
    function(connectReason) {
        // Get threshold callbacks with a debounce time of 10 seconds (10000ms)
        al.setDebouncePeriod(10000);
        // Configure threshold for "greater than 200 Lux" (unit is Lux/100)
        al.setIlluminanceCallbackThreshold('>', 200*100, 0);
    }
);

// Register threshold reached callback to function cb_reached
al.on(Tinkerforge.BrickletAmbientLightV2.CALLBACK_ILLUMINANCE_REACHED,
    // Callback for illuminance greater than 200 Lux
    function(illuminance) {
        console.log('We have ' +illuminance/100 + ' Lux.');
        console.log('Too bright, close the curtains!');
    }
);

console.log("Press any key to exit ...");
process.stdin.on('data',
    function(data) {
        ipcon.disconnect();
        process.exit(0);
    }
);