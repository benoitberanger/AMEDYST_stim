function Move( self, R, THETA )
% Note: R and THETA can be empty (no modifiaction) or not

% --- R ----
if ~isempty(R)
    assert( isscalar(R) && isnumeric(R) && R>=0 , ...
        'R = radius from Xorigin Yorigin, in pixels' )
    self.R = R;
end

% --- THETA ----
if ~isempty(THETA)
    assert( isscalar(THETA) && isnumeric(THETA) , ...
        'THETHA = angle from Xorigin Yorigin, in degrees' )
    self.THETA = THETA;
end

% In local canonical space, with Xorigin Yorigin as center
X = self.R * cos(self.THETA *pi/180);
Y = self.R * sin(self.THETA *pi/180);

self.Xptb =  X + self.Xorigin                ;
self.Yptb = -Y - self.Yorigin + self.screenY ;

self.currentRect = CenterRectOnPoint(self.currentRect, self.Xptb, self.Yptb);

end % function
