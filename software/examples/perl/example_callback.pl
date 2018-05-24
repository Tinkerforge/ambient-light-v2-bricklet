#!/usr/bin/perl

use strict;
use Tinkerforge::IPConnection;
use Tinkerforge::BrickletAmbientLightV2;

use constant HOST => 'localhost';
use constant PORT => 4223;
use constant UID => 'XYZ'; # Change XYZ to the UID of your Ambient Light Bricklet 2.0

# Callback subroutine for illuminance callback
sub cb_illuminance
{
    my ($illuminance) = @_;

    print "Illuminance: " . $illuminance/100.0 . " lx\n";
}

my $ipcon = Tinkerforge::IPConnection->new(); # Create IP connection
my $al = Tinkerforge::BrickletAmbientLightV2->new(&UID, $ipcon); # Create device object

$ipcon->connect(&HOST, &PORT); # Connect to brickd
# Don't use device before ipcon is connected

# Register illuminance callback to subroutine cb_illuminance
$al->register_callback($al->CALLBACK_ILLUMINANCE, 'cb_illuminance');

# Set period for illuminance callback to 1s (1000ms)
# Note: The illuminance callback is only called every second
#       if the illuminance has changed since the last call!
$al->set_illuminance_callback_period(1000);

print "Press key to exit\n";
<STDIN>;
$ipcon->disconnect();
