function Draw( obj )

obj.AssertReady

Screen('FillOval',obj.wPtr,...
    obj.diskCurrentColor,...
    obj.Rect);

end % function
