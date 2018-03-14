function [ symbol ] = Symbol
global S

Xorigin    = S.PTB.CenterH;
Yorigin    = S.PTB.CenterV;
screenX    = S.PTB.wRect(3);
screenY    = S.PTB.wRect(4);

switch S.Task
    case 'ADAPT_LowReward'
        filename = fullfile(pwd,'img','Stim111.bmp');
    case 'ADAPT_HighReward'
        filename = fullfile(pwd,'img','Stim112.bmp');
    otherwise
        error('task ?')
end

symbol = ImagePolar(filename, Xorigin, Yorigin, screenX, screenY);

% BMP special teatment
symbol.map = 0; % no need for these pictures
symbol.alpha = ones(size(symbol.X,1),size(symbol.X,2),'uint8')*255;

symbol.LinkToWindowPtr(S.PTB.wPtr);
symbol.MakeTexture;

symbol.AssertReady % just to check

end % function
