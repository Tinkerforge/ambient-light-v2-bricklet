var Tinkerforge = require('tinkerforge');

var HOST = 'localhost';
var PORT = 4223;
var UID = 'XYZ'; // Change XYZ to the UID of your Ambient Light Bricklet 2.0

var ipcon = new Tinkerforge.IPConnection(); // Create IP connection
var al = new Tinkerforge.BrickletAmbientLightV2(UID, ipcon); // Create device object

ipcon.connect(HOST, PORT,
    function (error) {
        console.log('Error: ' + error);
    }
); // Connect to brickd
// Don't use device before ipcon is connected

ipcon.on(Tinkerforge.IPConnection.CALLBACK_CONNECTED,
    function (connectReason) {
        // Get threshold callbacks with a debounce time of 10 seconds (10000ms)
        al.setDebouncePeriod(10000);

        // Configure threshold for illuminance "greater than 500 lx"
        al.setIlluminanceCallbackThreshold('>', 500*100, 0);
    }
);

// Register illuminance reached callback
al.on(Tinkerforge.BrickletAmbientLightV2.CALLBACK_ILLUMINANCE_REACHED,
    // Callback function for illuminance reached callback
    function (illuminance) {
        console.log('Illuminance: ' + illuminance/100.0 + ' lx');
        console.log('Too bright, close the curtains!');
    }
);

console.log('Press key to exit');
process.stdin.on('data',
    function (data) {
        ipcon.disconnect();
        process.exit(0);
    }
);
