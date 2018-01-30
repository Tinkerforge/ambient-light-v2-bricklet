function octave_example_callback()
    more off;

    HOST = "localhost";
    PORT = 4223;
    UID = "XYZ"; % Change XYZ to the UID of your Ambient Light Bricklet 2.0

    ipcon = javaObject("com.tinkerforge.IPConnection"); % Create IP connection
    al = javaObject("com.tinkerforge.BrickletAmbientLightV2", UID, ipcon); % Create device object

    ipcon.connect(HOST, PORT); % Connect to brickd
    % Don't use device before ipcon is connected

    % Register illuminance callback to function cb_illuminance
    al.addIlluminanceCallback(@cb_illuminance);

    % Set period for illuminance callback to 1s (1000ms)
    % Note: The illuminance callback is only called every second
    %       if the illuminance has changed since the last call!
    al.setIlluminanceCallbackPeriod(1000);

    input("Press key to exit\n", "s");
    ipcon.disconnect();
end

% Callback function for illuminance callback
function cb_illuminance(e)
    fprintf("Illuminance: %g lx\n", java2int(e.illuminance)/100.0);
end

function int = java2int(value)
    if compare_versions(version(), "3.8", "<=")
        int = value.intValue();
    else
        int = value;
    end
end
