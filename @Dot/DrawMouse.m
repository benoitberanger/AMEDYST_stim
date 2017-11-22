function DrawMouse( obj )

[x,y] = GetMouse(obj.wPtr);

obj.AssertReady

Screen('FillOval',obj.wPtr,...
    obj.diskCurrentColor,...
    CenterRectOnPoint([0 0 obj.diameter obj.diameter], x, y));

end % function
