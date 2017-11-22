function Move( obj, R, THETA )
% Note: R and THETA can be empty (no modifiaction) or not

% --- R ----
if ~isempty(R)
    assert( isscalar(R) && isnumeric(R) && R>=0 , ...
        'R = radius from Xorigin Yorigin, in pixels' )
    obj.R = R;
end

% --- THETA ----
if ~isempty(THETA)
    assert( isscalar(THETA) && isnumeric(THETA) , ...
        'THETHA = angle from Xorigin Yorigin, in degrees' )
    obj.THETA = THETA;
end

% In local canonical space, with Xorigin Yorigin as center
X = obj.R * cos(obj.THETA *pi/180);
Y = obj.R * sin(obj.THETA *pi/180);

obj.Xptb =  X + obj.Xorigin               ;
obj.Yptb = -Y - obj.Yorigin + obj.screenY ;

obj.Rect = CenterRectOnPoint([0 0 obj.diameter obj.diameter], obj.Xptb, obj.Yptb);

end % function
