function Move( obj, R, THETA )

% --- R ----
assert( isscalar(R) && isnumeric(R) && R>=0 , ...
    'R = radius from Xorigin Yorigin, in pixels' )

% --- THETA ----
assert( isscalar(THETA) && isnumeric(THETA) , ...
    'THETHA = angle from Xorigin Yorigin, in degrees' )

% In local canonical space, with Xorigin Yorigin as center
X = R * cos(THETA *pi/180);
Y = R * sin(THETA *pi/180);

obj.Xptb =  X + obj.Xorigin               ;
obj.Yptb = -Y - obj.Yorigin + obj.screenY ;

obj.Rect = CenterRectOnPoint([0 0 obj.diameter obj.diameter], obj.Xptb, obj.Yptb);

end % function
