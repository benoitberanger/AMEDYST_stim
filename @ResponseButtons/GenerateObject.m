function GenerateObject( obj )

% Width of the frame
obj.width = 2*obj.height;

%% Base

% Rectangle of the frame coordinates
obj.frameRect = [0 0 obj.width obj.height];
obj.frameRect = CenterRectOnPoint(obj.frameRect, obj.center(1), obj.center(2) );


%% Ovals

NrButtons = 4;
buttonDiameter = obj.width/(NrButtons+1);
spacing = buttonDiameter/(NrButtons+1);

xpos = @(oval) buttonDiameter/2+spacing + (buttonDiameter+spacing)*(oval-1) + obj.center(1)-obj.width/2;
ypos = [+5 -5 -5 +5]; % percetage of displacement from the center

for b = 1 : NrButtons
    obj.ovalRect(1:4,b) = CenterRectOnPoint( ...
        [0 0 buttonDiameter buttonDiameter], ...
        xpos(b), ...
        obj.center(2)*(1+ypos(b)/100) )';
end


%% Right side

% Swap color if RIGHT
if strcmpi(obj.side(1),'r')
   obj.ovalBaseColor = fliplr(obj.ovalBaseColor);
   obj.f2i = @(f) f-1;
else % left
    obj.f2i = @(f) -f+6;
end

obj.ovalCurrentColor = obj.ovalBaseColor;


%% Dark ovals

obj.darkOvals = repmat(obj.frameColor',[1 4])*0.8;


end % function
