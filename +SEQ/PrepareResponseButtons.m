function [ Buttons ] = PrepareResponseButtons
global S

height    = round(S.PTB.wRect(end)*S.Parameters.SEQ.ResponseButtons.ScreenRatio);
side      = S.Parameters.SEQ.ResponseButtons.Side;
center    = [S.PTB.CenterH S.PTB.CenterV];
baseColor = S.Parameters.SEQ.ResponseButtons.baseColor;
ovalColor = S.Parameters.SEQ.ResponseButtons.buttonsColor;

Buttons = ResponseButtons( height , side , center, baseColor, ovalColor );

Buttons.LinkToWindowPtr( S.PTB.wPtr )

Buttons.AssertReady % just to check

end % function
