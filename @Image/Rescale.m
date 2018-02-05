function prevScale = Rescale( self, newScale )

assert( isnumeric(newScale) && isscalar(newScale) && newScale>0, 'newScale must be a positive scalar value' )

prevScale = self.scale;

self.scale = newScale;

self.GenerateRect;

end % function
