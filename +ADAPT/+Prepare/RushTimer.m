function [ timer ] = RushTimer( Parameters )
global S

min    = 0;
max    = Parameters.TrialMaxDuration;
width  = S.PTB.wRect(3);
height = S.PTB.wRect(4);
ratio   = S.Parameters.ADAPT.Timer.ScreenRation;

timer = RushTimer(...
    min,...
    max,...
    width,...
    height,...
    ratio...
    );

timer.LinkToWindowPtr( S.PTB.wPtr )

timer.AssertReady % just to check

end % function
