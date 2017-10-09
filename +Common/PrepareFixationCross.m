function [ WhiteCross ] = PrepareFixationCross
global S

WhiteCross = FixationCross( round(S.PTB.wRect(end)/30) , 2 ,  [255 255 255 255] , [S.PTB.CenterH S.PTB.CenterV] );

WhiteCross.LinkToWindowPtr( S.PTB.wPtr )

WhiteCross.AssertReady % just to check

end % function
