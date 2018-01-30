function matlab_example_simple()
    import com.tinkerforge.IPConnection;
    import com.tinkerforge.BrickletAmbientLightV2;

    HOST = 'localhost';
    PORT = 4223;
    UID = 'XYZ'; % Change XYZ to the UID of your Ambient Light Bricklet 2.0

    ipcon = IPConnection(); % Create IP connection
    al = handle(BrickletAmbientLightV2(UID, ipcon), 'CallbackProperties'); % Create device object

    ipcon.connect(HOST, PORT); % Connect to brickd
    % Don't use device before ipcon is connected

    % Get current illuminance
    illuminance = al.getIlluminance();
    fprintf('Illuminance: %g lx\n', illuminance/100.0);

    input('Press key to exit\n', 's');
    ipcon.disconnect();
end
