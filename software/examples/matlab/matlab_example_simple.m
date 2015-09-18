function matlab_example_simple()
    import com.tinkerforge.IPConnection;
    import com.tinkerforge.BrickletAmbientLightV2;

    HOST = 'localhost';
    PORT = 4223;
    UID = 'XYZ'; % Change to your UID

    ipcon = IPConnection(); % Create IP connection
    al = BrickletAmbientLightV2(UID, ipcon); % Create device object

    ipcon.connect(HOST, PORT); % Connect to brickd
    % Don't use device before ipcon is connected

    % Get current illuminance (unit is Lux/100)
    illuminance = al.getIlluminance();
    fprintf('Illuminance: %g Lux\n', illuminance/100.0);

    input('Press key to exit\n', 's');
    ipcon.disconnect();
end
