function octave_example_simple()
    more off;

    HOST = "localhost";
    PORT = 4223;
    UID = "amb2"; % Change to your UID

    ipcon = java_new("com.tinkerforge.IPConnection"); % Create IP connection
    al = java_new("com.tinkerforge.BrickletAmbientLightV2", UID, ipcon); % Create device object

    ipcon.connect(HOST, PORT); % Connect to brickd
    % Don't use device before ipcon is connected

    % Get current illuminance (unit is Lux/100)
    illuminance = al.getIlluminance();
    fprintf("Illuminance: %g Lux\n", long2int(illuminance)/100.0);

    input("Press any key to exit...\n", "s");
    ipcon.disconnect();
end

function int = long2int(long)
    if compare_versions(version(), "3.8", "<=")
        int = long.intValue();
    else
        int = long;
    end
end
