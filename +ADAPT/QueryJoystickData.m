function [X, Y] = QueryJoystickData( ScreenWidth, ScreenHeight )

data = joymex2('query',0);

% Raw data
X = double( data.axes(1));
Y = double(-data.axes(2));

% % Joystick scale correction
% if X > 0
%     X = X * 2^15/26945;
% else
%     X = X * 2^15/21568;
% end
% if Y > 0
%     Y = Y * 2^15/20416;
% else
%     Y = Y * 2^15/15677;
% end
% 
% % Origin correction
% X0 = -1025;
% Y0 =  1281;
% X = (X - X0);
% Y = (Y - Y0);

% Scale data to screen
X = X/2^15 * ScreenHeight/2;
Y = Y/2^15 * ScreenHeight/2;

end % function
