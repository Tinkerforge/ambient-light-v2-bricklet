function matlab_example_callback()
    import com.tinkerforge.IPConnection;
    import com.tinkerforge.BrickletAmbientLightV2;

    HOST = 'localhost';
    PORT = 4223;
    UID = 'XYZ'; % Change to your UID

    ipcon = IPConnection(); % Create IP connection
    al = handle(BrickletAmbientLightV2(UID, ipcon), 'CallbackProperties'); % Create device object

    ipcon.connect(HOST, PORT); % Connect to brickd
    % Don't use device before ipcon is connected

    % Register illuminance callback to function cb_illuminance
    set(al, 'IlluminanceCallback', @(h, e) cb_illuminance(e));

    % Set period for illuminance callback to 1s (1000ms)
    % Note: The illuminance callback is only called every second
    %       if the illuminance has changed since the last call!
    al.setIlluminanceCallbackPeriod(1000);

    input('Press key to exit\n', 's');
    ipcon.disconnect();
end

% Callback function for illuminance callback (parameter has unit Lux/100)
function cb_illuminance(e)
    fprintf('Illuminance: %g Lux\n', e.illuminance/100.0);
end
