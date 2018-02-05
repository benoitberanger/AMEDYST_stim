function [ prevRect ] = GenerateRect( self )

prevRect = self.currentRect;

self.currentRect = CenterRectOnPoint( ScaleRect(self.baseRect, self.scale, self.scale) ,...
    self.center(1), ...
    self.center(2) );

end % function
