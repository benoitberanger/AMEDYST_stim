function [ BigCircle ] = PrepareBigCircle
global S

diameter  = S.Parameters.ADAPT.Circle.DimensionRatio*S.PTB.wRect(4);
thickness = S.Parameters.ADAPT.Circle.WidthRatio*S.PTB.wRect(4);
color     = S.Parameters.ADAPT.Circle.Color;
Xorigin   = S.PTB.CenterH;
Yorigin   = S.PTB.CenterV;
screenX   = S.PTB.wRect(3);
screenY   = S.PTB.wRect(4);

BigCircle = Circle(...
    diameter   ,...     % diameter  in pixels
    thickness  ,...     % thickness in pixels
    color      ,...     % color     [R G B] 0-255
    Xorigin    ,...     % X origin  in pixels
    Yorigin    ,...     % Y origin  in pixels
    screenX    ,...     % H pixels of the screen
    screenY    );       % V pixels of the screen

BigCircle.LinkToWindowPtr( S.PTB.wPtr )

BigCircle.AssertReady % just to check

end % function
