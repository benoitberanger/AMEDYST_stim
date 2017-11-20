function [ Buttons ] = PrepareResponseButtons
global S

height    = round(S.PTB.wRect(end)*S.Parameters.SEQ.ResponseButtons.ScreenRatio);
side      = S.Parameters.SEQ.ResponseButtons.Side;
center    = [S.PTB.CenterH S.PTB.CenterV];
frameColor= S.Parameters.SEQ.ResponseButtons.frameColor;
ovalColor = S.Parameters.SEQ.ResponseButtons.buttonsColor;

Buttons = ResponseButtons( height , side , center, frameColor, ovalColor );

Buttons.LinkToWindowPtr( S.PTB.wPtr )

Buttons.AssertReady % just to check

end % function
