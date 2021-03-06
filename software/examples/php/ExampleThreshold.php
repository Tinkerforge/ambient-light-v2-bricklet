<?php

require_once('Tinkerforge/IPConnection.php');
require_once('Tinkerforge/BrickletAmbientLightV2.php');

use Tinkerforge\IPConnection;
use Tinkerforge\BrickletAmbientLightV2;

const HOST = 'localhost';
const PORT = 4223;
const UID = 'XYZ'; // Change XYZ to the UID of your Ambient Light Bricklet 2.0

// Callback function for illuminance reached callback
function cb_illuminanceReached($illuminance)
{
    echo "Illuminance: " . $illuminance/100.0 . " lx\n";
    echo "Too bright, close the curtains!\n";
}

$ipcon = new IPConnection(); // Create IP connection
$al = new BrickletAmbientLightV2(UID, $ipcon); // Create device object

$ipcon->connect(HOST, PORT); // Connect to brickd
// Don't use device before ipcon is connected

// Get threshold callbacks with a debounce time of 10 seconds (10000ms)
$al->setDebouncePeriod(10000);

// Register illuminance reached callback to function cb_illuminanceReached
$al->registerCallback(BrickletAmbientLightV2::CALLBACK_ILLUMINANCE_REACHED,
                      'cb_illuminanceReached');

// Configure threshold for illuminance "greater than 500 lx"
$al->setIlluminanceCallbackThreshold('>', 500*100, 0);

echo "Press ctrl+c to exit\n";
$ipcon->dispatchCallbacks(-1); // Dispatch callbacks forever

?>
