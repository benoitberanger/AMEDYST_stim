function Draw( self, content )

if nargin > 1
    self.content = content;
end

DrawFormattedText(self.wPtr, self.content, self.Xptb, self.Yptb, self.color);

end % function
