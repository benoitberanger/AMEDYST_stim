function Move( obj, X, Y )
% Note: X and Y can be empty (no modifiaction) or not

% --- X ----
if ~isempty(X)
    assert( isscalar(X) && isnumeric(X) , ...
        'X = radius from Xorigin Yorigin, in pixels' )
    obj.X = X;
end

% --- Y ----
if ~isempty(Y)
    assert( isscalar(Y) && isnumeric(Y) , ...
        'Y = angle from Xorigin Yorigin, in degrees' )
    obj.Y = Y;
end

obj.R     = sqrt(obj.X*obj.X + obj.Y*obj.Y); % pixels
obj.Theta = atan2(obj.Y,obj.X) * 180/pi    ; % rad

obj.Xptb =  obj.X + obj.Xorigin               ;
obj.Yptb = -obj.Y - obj.Yorigin + obj.screenY ;

obj.Rect = CenterRectOnPoint([0 0 obj.diameter obj.diameter], obj.Xptb, obj.Yptb);

end % function
