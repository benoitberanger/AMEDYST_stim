function Draw( obj )

obj.AssertReady

Screen('DrawLines', obj.wPtr, obj.allCoords,...
    obj.width, obj.color, obj.center);

end
