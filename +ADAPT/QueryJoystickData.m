function [X, Y] = QueryJoystickData( ScreenWidth, ScreenHeight )
global S

data = joymex2('query',0);

% Raw data
X = double( data.axes(1));
Y = double(-data.axes(2));

% Joystick scale correction
if X > 0
    X =  X / S.xmin_ymin_xmax_ymax(3);
else
    X = -X / S.xmin_ymin_xmax_ymax(1);
end
if Y > 0
    Y =  Y / S.xmin_ymin_xmax_ymax(4);
else
    Y = -Y / S.xmin_ymin_xmax_ymax(2);
end

% Scale data to screen
X = X * ScreenHeight/2;
Y = Y * ScreenHeight/2;

end % function
