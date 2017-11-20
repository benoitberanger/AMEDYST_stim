function DrawOval( obj, finger )

if isempty(finger)
    
    Screen('FillOval', obj.wPtr, obj.darkOvals, obj.ovalRect);
    
else
    
    % finger goes from 5 to 2, but the matrix index go from 1 to 4qsdfqsdfljkh
    
    idx = obj.f2i(finger);
    
    currentColors = obj.darkOvals;
    currentColors(:,idx) = obj.ovalCurrentColor(:,idx);
    
    Screen('FillOval', obj.wPtr, currentColors, obj.ovalRect);
    
end

end % function
