function DrawMouse( obj )

obj.AssertReady

[x,y] = GetMouse(obj.wPtr);

Screen('FillOval',obj.wPtr,...
    obj.diskCurrentColor,...
    CenterRectOnPoint([0 0 obj.diameter obj.diameter], x, y));

end % function
