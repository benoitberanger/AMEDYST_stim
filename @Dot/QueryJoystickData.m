function QueryJoystickData( obj )

data = joymex2('query',0);

obj.X = double( data.axes(1))/2^15 * obj.screenX/2;
obj.Y = double(-data.axes(2))/2^15 * obj.screenY/2;

end % function
