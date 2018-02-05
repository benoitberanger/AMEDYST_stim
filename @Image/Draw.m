function Draw( self, status )

if nargin < 2
    status = 1;
end

switch status
    case 1
        Screen('DrawTexture', self.wPtr, self.texturePtr , [],  self.currentRect);
    case 0
        Screen('FillRect', self.wPtr ,self.currentColor, self.currentRect);
    otherwise
        error('status must be 0 or 1')
end % switch

end % function
