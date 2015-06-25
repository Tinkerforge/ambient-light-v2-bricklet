function octave_example_threshold()
    more off;

    HOST = "localhost";
    PORT = 4223;
    UID = "amb2"; % Change to your UID

    ipcon = java_new("com.tinkerforge.IPConnection"); % Create IP connection
    al = java_new("com.tinkerforge.BrickletAmbientLightV2", UID, ipcon); % Create device object

    ipcon.connect(HOST, PORT); % Connect to brickd
    % Don't use device before ipcon is connected

    % Set threshold callbacks with a debounce time of 10 seconds (10000ms)
    al.setDebouncePeriod(10000);

    % Configure threshold for "greater than 200 Lux" (unit is Lux/100)
    al.setIlluminanceCallbackThreshold(al.THRESHOLD_OPTION_GREATER, 200*100, 0);

    % Register threshold reached callback to function cb_reached
    al.addIlluminanceReachedCallback(@cb_reached);

    input("Press any key to exit...\n", "s");
    ipcon.disconnect();
end

% Callback function for illuminance callback (parameter has unit Lux/100)
function cb_reached(e)
    fprintf("We have %g Lux.\n", long2int(e.illuminance)/100.0);
    fprintf("Too bright, close the curtains!\n")
end

function int = long2int(long)
    if compare_versions(version(), "3.8", "<=")
        int = long.intValue();
    else
        int = long;
    end
end
