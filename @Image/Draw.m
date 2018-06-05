function Draw( self, status )

if nargin < 2
    status = 1;
end

switch status
    case 1
        Screen('DrawTexture', self.wPtr, self.texturePtr , [],  self.currentRect);
    case 0
        % Screen('FillOval', self.wPtr ,self.currentColor, self.currentRect);
        Screen('DrawTexture', self.wPtr, self.texturePtr , [],  self.currentRect);
        Screen('DrawLine'   , self.wPtr , [255 0 0] , self.currentRect(1), self.currentRect(2), self.currentRect(3), self.currentRect(4) , self.baseRect(end)/50);
        Screen('DrawLine'   , self.wPtr , [255 0 0] , self.currentRect(1), self.currentRect(4), self.currentRect(3), self.currentRect(2) , self.baseRect(end)/50);
    otherwise
        error('status must be 0 or 1')
end % switch

end % function
