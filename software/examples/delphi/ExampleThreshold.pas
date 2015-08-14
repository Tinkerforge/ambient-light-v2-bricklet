program ExampleThreshold;

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
    procedure IlluminanceReachedCB(sender: TBrickletAmbientLightV2; const illuminance: longword);
    procedure Execute;
  end;

const
  HOST = 'localhost';
  PORT = 4223;
  UID = 'XYZ'; { Change to your UID }

var
  e: TExample;

{ Callback procedure for illuminance greater than 1000 Lux (parameter has unit Lux/100) }
procedure TExample.IlluminanceReachedCB(sender: TBrickletAmbientLightV2; const illuminance: longword);
begin
  WriteLn(Format('Illuminance: %f Lux', [illuminance/100.0]));
  WriteLn('Too bright, close the curtains!');
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

  { Get threshold callbacks with a debounce time of 10 seconds (10000ms) }
  al.SetDebouncePeriod(10000);

  { Register threshold reached callback to procedure IlluminanceReachedCB }
  al.OnIlluminanceReached := {$ifdef FPC}@{$endif}IlluminanceReachedCB;

  { Configure threshold for "greater than 1000 Lux" (unit is Lux/100) }
  al.SetIlluminanceCallbackThreshold('>', 1000*100, 0);

  WriteLn('Press key to exit');
  ReadLn;
  ipcon.Destroy; { Calls ipcon.Disconnect internally }
end;

begin
  e := TExample.Create;
  e.Execute;
  e.Destroy;
end.
