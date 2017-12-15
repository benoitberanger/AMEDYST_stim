function [ reward ] = Reward
global S

color   = S.Parameters.Text.Color;
content = 0;
Xptb    = 'center';
Yptb    = 'center';


reward = Text(color, content, Xptb, Yptb);

reward.LinkToWindowPtr( S.PTB.wPtr )

reward.AssertReady % just to check

end % function
