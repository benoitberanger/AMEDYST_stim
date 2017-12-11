function DrawDisk( obj )

% Mask, to fill the hole
Screen('FillOval',obj.wPtr,...
    obj.diskCurrentColor,...
    obj.Rect);

end % function
