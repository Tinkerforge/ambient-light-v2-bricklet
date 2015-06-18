program ExampleCallback;

{$ifdef MSWINDOWS}{$apptype CONSOLE}{$endif}
{$ifdef FPC}{$mode OBJFPC}{$H+}{$endif}

uses
  SysUtils, IPConnection, BrickletAmbientLightV2;

type
  TExample = class
  private
    ipcon: TIPConnection;
    al: TBrickletAmbientLightV2;
  public
    procedure IlluminanceCB(sender: TBrickletAmbientLightV2; const illuminance: longword);
    procedure Execute;
  end;

const
  HOST = 'localhost';
  PORT = 4223;
  UID = 'XYZ'; { Change to your UID }

var
  e: TExample;

{ Callback function for illuminance callback (parameter has unit Lux/100) }
procedure TExample.IlluminanceCB(sender: TBrickletAmbientLightV2; const illuminance: longword);
begin
  WriteLn(Format('Illuminance: %f Lux', [illuminance/100.0]));
end;

procedure TExample.Execute;
begin
  { Create IP connection }
  ipcon := TIPConnection.Create;

  { Create device object }
  al := TBrickletAmbientLightV2.Create(UID, ipcon);

  { Connect to brickd }
  ipcon.Connect(HOST, PORT);
  { Don't use device before ipcon is connected }

  { Set Period for illuminance callback to 1s (1000ms)
    Note: The illuminance callback is only called every second if the
          illuminance has changed since the last call! }
  al.SetIlluminanceCallbackPeriod(1000);

  { Register illuminance callback to procedure IlluminanceCB }
  al.OnIlluminance := {$ifdef FPC}@{$endif}IlluminanceCB;

  WriteLn('Press key to exit');
  ReadLn;
  ipcon.Destroy; { Calls ipcon.Disconnect internally }
end;

begin
  e := TExample.Create;
  e.Execute;
  e.Destroy;
end.
