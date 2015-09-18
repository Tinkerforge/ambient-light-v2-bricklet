#!/usr/bin/perl

use Tinkerforge::IPConnection;
use Tinkerforge::BrickletAmbientLightV2;

use constant HOST => 'localhost';
use constant PORT => 4223;
use constant UID => 'XYZ'; # Change to your UID

my $ipcon = Tinkerforge::IPConnection->new(); # Create IP connection
my $al = Tinkerforge::BrickletAmbientLightV2->new(&UID, $ipcon); # Create device object

$ipcon->connect(&HOST, &PORT); # Connect to brickd
# Don't use device before ipcon is connected

# Get current illuminance (unit is Lux/100)
my $illuminance = $al->get_illuminance();
print "Illuminance: " . $illuminance/100.0 . " Lux\n";

print "Press key to exit\n";
<STDIN>;
$ipcon->disconnect();
