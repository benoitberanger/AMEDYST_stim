function DrawOval( obj, finger )

if isempty(finger)
    
    Screen('FillOval', obj.wPtr, obj.darkOvals, obj.ovalRect);
    
else
    
    % finger goes from 5 to 2, but the matrix index go from 1 to 4
    
    currentColors = obj.darkOvals;
    currentColors(:,-finger+6) = obj.ovalColor(:,-finger+6);
    
    Screen('FillOval', obj.wPtr, currentColors, obj.ovalRect);
    
end

end % function
