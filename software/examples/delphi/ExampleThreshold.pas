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
    procedure ReachedCB(sender: TBrickletAmbientLightV2; const illuminance: LongWord);
    procedure Execute;
  end;

const
  HOST = 'localhost';
  PORT = 4223;
  UID = 'XYZ'; { Change to your UID }

var
  e: TExample;

{ Callback for illuminance greater than 200 Lux }
procedure TExample.ReachedCB(sender: TBrickletAmbientLightV2; const illuminance: LongWord);
begin
  WriteLn(Format('We have %f Lux.', [illuminance/100.0]));
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

  { Register threshold reached callback to procedure ReachedCB }
  al.OnIlluminanceReached := {$ifdef FPC}@{$endif}ReachedCB;

  { Configure threshold for "greater than 200 Lux" (unit is Lux/100) }
  al.SetIlluminanceCallbackThreshold('>', 200*100, 0);

  WriteLn('Press key to exit');
  ReadLn;
  ipcon.Destroy; { Calls ipcon.Disconnect internally }
end;

begin
  e := TExample.Create;
  e.Execute;
  e.Destroy;
end.
