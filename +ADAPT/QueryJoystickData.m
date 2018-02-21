function [X, Y] = QueryJoystickData( ScreenWidth, ScreenHeight )

data = joymex2('query',0);

% Scale data to screen
X = double( data.axes(1))/2^15 * ScreenWidth /2;
Y = double(-data.axes(2))/2^15 * ScreenHeight/2;

% Joystick scale correction
if X > 0
    X = X * 2^15/28500;
end
if Y < 0
    Y = Y * 2^15/30100;
end

end % function
