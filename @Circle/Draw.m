function Draw( obj )

obj.AssertReady

Screen('FrameOval',obj.wPtr,...
    obj.currentColor,...
    obj.Rect,...
    obj.thickness);

end % function
