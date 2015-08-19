#!/usr/bin/perl

use Tinkerforge::IPConnection;
use Tinkerforge::BrickletAmbientLightV2;

use constant HOST => 'localhost';
use constant PORT => 4223;
use constant UID => 'XYZ'; # Change to your UID

my $ipcon = Tinkerforge::IPConnection->new(); # Create IP connection
my $al = Tinkerforge::BrickletAmbientLightV2->new(&UID, $ipcon); # Create device object

# Callback subroutine for illuminance greater than 1000 Lux (parameter has unit Lux/100)
sub cb_illuminance_reached
{
    my ($illuminance) = @_;

    print "Illuminance: " . $illuminance/100.0 . " Lux\n";
    print "Too bright, close the curtains!";
}

$ipcon->connect(&HOST, &PORT); # Connect to brickd
# Don't use device before ipcon is connected

# Get threshold callbacks with a debounce time of 10 seconds (10000ms)
$al->set_debounce_period(10000);

# Register threshold reached callback to subroutine cb_illuminance_reached
$al->register_callback($al->CALLBACK_ILLUMINANCE_REACHED, 'cb_illuminance_reached');

# Configure threshold for "greater than 1000 Lux" (unit is Lux/100)
$al->set_illuminance_callback_threshold('>', 1000*100, 0);

print "Press any key to exit...\n";
<STDIN>;
$ipcon->disconnect();
