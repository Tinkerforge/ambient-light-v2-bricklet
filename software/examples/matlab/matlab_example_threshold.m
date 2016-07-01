function matlab_example_threshold()
    import com.tinkerforge.IPConnection;
    import com.tinkerforge.BrickletAmbientLightV2;

    HOST = 'localhost';
    PORT = 4223;
    UID = 'XYZ'; % Change XYZ to the UID of your Ambient Light Bricklet 2.0

    ipcon = IPConnection(); % Create IP connection
    al = handle(BrickletAmbientLightV2(UID, ipcon), 'CallbackProperties'); % Create device object

    ipcon.connect(HOST, PORT); % Connect to brickd
    % Don't use device before ipcon is connected

    % Get threshold callbacks with a debounce time of 10 seconds (10000ms)
    al.setDebouncePeriod(10000);

    % Register illuminance reached callback to function cb_illuminance_reached
    set(al, 'IlluminanceReachedCallback', @(h, e) cb_illuminance_reached(e));

    % Configure threshold for illuminance "greater than 500 Lux" (unit is Lux/100)
    al.setIlluminanceCallbackThreshold('>', 500*100, 0);

    input('Press key to exit\n', 's');
    ipcon.disconnect();
end

% Callback function for illuminance reached callback (parameter has unit Lux/100)
function cb_illuminance_reached(e)
    fprintf('Illuminance: %g Lux\n', e.illuminance/100.0);
    fprintf('Too bright, close the curtains!\n');
end
