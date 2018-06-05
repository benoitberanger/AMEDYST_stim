function [ probability ] = Probability
global S

color   = S.Parameters.Text.Color;
content = 'EMPTY';
Xptb    = 'center';
Yptb    = 'center';

probability = Text(...
    color   ,...
    content ,...
    Xptb    ,...
    Yptb    );

probability.LinkToWindowPtr( S.PTB.wPtr )

probability.AssertReady % just to check

end % function
