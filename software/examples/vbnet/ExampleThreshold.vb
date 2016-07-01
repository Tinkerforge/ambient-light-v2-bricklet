Imports System
Imports Tinkerforge

Module ExampleThreshold
    Const HOST As String = "localhost"
    Const PORT As Integer = 4223
    Const UID As String = "XYZ" ' Change XYZ to the UID of your Ambient Light Bricklet 2.0

    ' Callback subroutine for illuminance reached callback (parameter has unit Lux/100)
    Sub IlluminanceReachedCB(ByVal sender As BrickletAmbientLightV2, ByVal illuminance As Long)
        Console.WriteLine("Illuminance: " + (illuminance/100.0).ToString() + " Lux")
        Console.WriteLine("Too bright, close the curtains!")
    End Sub

    Sub Main()
        Dim ipcon As New IPConnection() ' Create IP connection
        Dim al As New BrickletAmbientLightV2(UID, ipcon) ' Create device object

        ipcon.Connect(HOST, PORT) ' Connect to brickd
        ' Don't use device before ipcon is connected

        ' Get threshold callbacks with a debounce time of 10 seconds (10000ms)
        al.SetDebouncePeriod(10000)

        ' Register illuminance reached callback to subroutine IlluminanceReachedCB
        AddHandler al.IlluminanceReached, AddressOf IlluminanceReachedCB

        ' Configure threshold for illuminance "greater than 500 Lux" (unit is Lux/100)
        al.SetIlluminanceCallbackThreshold(">"C, 500*100, 0)

        Console.WriteLine("Press key to exit")
        Console.ReadLine()
        ipcon.Disconnect()
    End Sub
End Module
