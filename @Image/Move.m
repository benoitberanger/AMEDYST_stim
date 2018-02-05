function prevCenter = Move( self, newCenter )

prevCenter = self.center;

assert( all(isnumeric(newCenter)) && all(size(newCenter)==[1 2]) , 'newCenter must be 1x2 numeric vector such as [X-center-PTB, Y-center-PTB]' )

self.center = newCenter;

self.GenerateRect;

end % function
