#!/usr/bin/perl

use strict;
use Tinkerforge::IPConnection;
use Tinkerforge::BrickletAmbientLightV2;

use constant HOST => 'localhost';
use constant PORT => 4223;
use constant UID => 'XYZ'; # Change XYZ to the UID of your Ambient Light Bricklet 2.0

# Callback subroutine for illuminance reached callback
sub cb_illuminance_reached
{
    my ($illuminance) = @_;

    print "Illuminance: " . $illuminance/100.0 . " lx\n";
    print "Too bright, close the curtains!\n";
}

my $ipcon = Tinkerforge::IPConnection->new(); # Create IP connection
my $al = Tinkerforge::BrickletAmbientLightV2->new(&UID, $ipcon); # Create device object

$ipcon->connect(&HOST, &PORT); # Connect to brickd
# Don't use device before ipcon is connected

# Get threshold callbacks with a debounce time of 10 seconds (10000ms)
$al->set_debounce_period(10000);

# Register illuminance reached callback to subroutine cb_illuminance_reached
$al->register_callback($al->CALLBACK_ILLUMINANCE_REACHED, 'cb_illuminance_reached');

# Configure threshold for illuminance "greater than 500 lx"
$al->set_illuminance_callback_threshold('>', 500*100, 0);

print "Press key to exit\n";
<STDIN>;
$ipcon->disconnect();
