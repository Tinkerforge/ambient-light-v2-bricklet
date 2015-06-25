function octave_example_callback()
    more off;

    HOST = "localhost";
    PORT = 4223;
    UID = "amb2"; % Change to your UID

    ipcon = java_new("com.tinkerforge.IPConnection"); % Create IP connection
    al = java_new("com.tinkerforge.BrickletAmbientLightV2", UID, ipcon); % Create device object

    ipcon.connect(HOST, PORT); % Connect to brickd
    % Don't use device before ipcon is connected

    % Set Period for illuminance callback to 1s (1000ms)
    % Note: The callback is only called every second if the
    %       illuminance has changed since the last call!
    al.setIlluminanceCallbackPeriod(1000);

    % Register illuminance callback to function cb_illuminance
    al.addIlluminanceCallback(@cb_illuminance);

    input("Press any key to exit...\n", "s");
    ipcon.disconnect();
end

% Callback function for illuminance callback (parameter has unit Lux/100)
function cb_illuminance(e)
    fprintf("Illuminance: %g Lux\n", long2int(e.illuminance)/100.0);
end

function int = long2int(long)
    if compare_versions(version(), "3.8", "<=")
        int = long.intValue();
    else
        int = long;
    end
end
