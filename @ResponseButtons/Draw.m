function Draw( obj, finger )

if ~exist('finger','var')
    finger = [];
end

obj.DrawBase
obj.DrawOval(finger)

end % function
