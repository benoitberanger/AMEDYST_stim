function QueryJoystickData( obj )

data = joymex2('query',0);

rawX = double( data.axes(1))/2^15 * obj.screenX/2;
rawY = double(-data.axes(2))/2^15 * obj.screenY/2;

% Correction
if rawX > 0
    rawX = rawX * 2^15/29700;
end
if rawY < 0
    rawY = rawY * 2^15/26100;
end

obj.X = rawX;
obj.Y = rawY;



end % function
