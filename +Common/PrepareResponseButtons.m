function [ Buttons ] = PrepareResponseButtons
global S

height    = round(S.PTB.wRect(end)*S.Parameters.ResponseButtons.ScreenRatio);
side      = S.Parameters.ResponseButtons.Side;
center    = [S.PTB.CenterH S.PTB.CenterV];
baseColor = S.Parameters.ResponseButtons.baseColor;
ovalColor = S.Parameters.ResponseButtons.buttonsColor;

Buttons = ResponseButtons( height , side , center, baseColor, ovalColor );

Buttons.LinkToWindowPtr( S.PTB.wPtr )

Buttons.AssertReady % just to check

end % function
