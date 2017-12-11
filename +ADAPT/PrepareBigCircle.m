function [ BigCircle ] = PrepareBigCircle
global S

diameter   = S.Parameters.ADAPT.Circle.DimensionRatio*S.PTB.wRect(4);
thickness  = S.Parameters.ADAPT.Circle.WidthRatio*diameter;
frameColor = S.Parameters.ADAPT.Circle.FrameColor;
diskColor  = S.Parameters.ADAPT.Circle.DiskColor;
valueColor = S.Parameters.ADAPT.Circle.ValueColor;
Xorigin    = S.PTB.CenterH;
Yorigin    = S.PTB.CenterV;
screenX    = S.PTB.wRect(3);
screenY    = S.PTB.wRect(4);

BigCircle = Circle(...
    diameter   ,...     % diameter  in pixels
    thickness  ,...     % thickness in pixels
    frameColor ,...     % frame color [R G B] 0-255
    diskColor  ,...     % disk  color [R G B] 0-255
    valueColor ,...     % disk  color [R G B] 0-255
    Xorigin    ,...     % X origin  in pixels
    Yorigin    ,...     % Y origin  in pixels
    screenX    ,...     % H pixels of the screen
    screenY    );       % V pixels of the screen

BigCircle.filled = 0; % only draw the frame, dont fill the disk inside

BigCircle.LinkToWindowPtr( S.PTB.wPtr )

BigCircle.AssertReady % just to check

end % function
