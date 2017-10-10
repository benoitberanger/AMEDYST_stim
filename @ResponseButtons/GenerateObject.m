function GenerateObject( obj )

% Width of the base
obj.width = 2*obj.height;

%% Base

% Rectangle of the base coordinates
obj.baseRect = [0 0 obj.width obj.height];
obj.baseRect = CenterRectOnPoint(obj.baseRect, obj.center(1), obj.center(2) );


%% Ovals

NrButtons = 4;
buttonDiameter = obj.width/(NrButtons+1);
spacing = buttonDiameter/(NrButtons+1);

xpos = @(oval) buttonDiameter/2+spacing + (buttonDiameter+spacing)*(oval-1) + obj.center(1)-obj.width/2;

for b = 1 : NrButtons
    obj.ovalRect(1:4,b) = CenterRectOnPoint([0 0 buttonDiameter buttonDiameter],xpos(b),obj.center(2))';
end


%% Dark ovals

obj.darkOvals = uint8(repmat(obj.baseColor',[1 4])*0.8);


end % function
