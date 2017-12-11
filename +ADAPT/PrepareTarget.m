function [ Target, PrevTarget ] = PrepareTarget
global S

diameter   = S.Parameters.ADAPT.Target.DimensionRatio*S.PTB.wRect(4);
thickness  = S.Parameters.ADAPT.Target.WidthRatio*diameter;
frameColor = S.Parameters.ADAPT.Target.FrameColor;
diskColor  = S.Parameters.ADAPT.Target.DiskColor;
valueColor = S.Parameters.ADAPT.Target.ValueColor;
Xorigin    = S.PTB.CenterH;
Yorigin    = S.PTB.CenterV;
screenX    = S.PTB.wRect(3);
screenY    = S.PTB.wRect(4);

Target = Circle(...
    diameter   ,...     % diameter  in pixels
    thickness  ,...     % thickness in pixels
    frameColor ,...     % frame color [R G B] 0-255
    diskColor ,...      % disk  color [R G B] 0-255
    valueColor ,...     % disk  color [R G B] 0-255
    Xorigin    ,...     % X origin  in pixels
    Yorigin    ,...     % Y origin  in pixels
    screenX    ,...     % H pixels of the screen
    screenY    );       % V pixels of the screen

Target.LinkToWindowPtr( S.PTB.wPtr )

Target.AssertReady % just to check

PrevTarget = Target.CopyObject;

% Switch the flag 'on' after the copy of the object
Target.valued = 1;

end % function
