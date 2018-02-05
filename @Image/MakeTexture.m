function [ texturePtr ] = MakeTexture( self )

assert(~isempty(self.wPtr), 'use LinkToWindowPtr first')

texturePtr = Screen('MakeTexture', self.wPtr, cat(3,self.X,self.alpha));

self.texturePtr = texturePtr;

end % function
