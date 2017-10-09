function [ Buttons ] = PrepareResponseButtons
global S

Buttons = ResponseButtons( round(S.PTB.wRect(end)*0.6) , 'Left' , [S.PTB.CenterH S.PTB.CenterV] );

Buttons.LinkToWindowPtr( S.PTB.wPtr )

Buttons.AssertReady % just to check

end % function
