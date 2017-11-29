function DrawMouse( obj )

obj.AssertReady

% Fetch data
[x,y] = GetMouse(obj.wPtr); % (x,y) in PTB coordiantes

% PTB coordinates to Origin coordinates
X =  x - obj.Xorigin               ;
Y = -y - obj.Yorigin + obj.screenY ;

obj.Move(X,Y);

% Draw
obj.Draw

end % function
