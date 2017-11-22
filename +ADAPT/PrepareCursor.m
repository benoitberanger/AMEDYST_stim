function [ Cursor ] = PrepareCursor
global S

diameter   = S.Parameters.ADAPT.Cursor.DimensionRatio*S.PTB.wRect(4);
diskColor  = S.Parameters.ADAPT.Cursor.DiskColor;
Xorigin    = S.PTB.CenterH;
Yorigin    = S.PTB.CenterV;
screenX    = S.PTB.wRect(3);
screenY    = S.PTB.wRect(4);

Cursor = Dot(...
    diameter   ,...     % diameter  in pixels
    diskColor ,...      % disk  color [R G B] 0-255
    Xorigin    ,...     % X origin  in pixels
    Yorigin    ,...     % Y origin  in pixels
    screenX    ,...     % H pixels of the screen
    screenY    );       % V pixels of the screen

Cursor.LinkToWindowPtr( S.PTB.wPtr )

Cursor.AssertReady % just to check

end % function
