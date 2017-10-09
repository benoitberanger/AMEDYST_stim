function [ ER, from, Exit_flag, StopTime ] = ControlCondition( EP, ER, RR, KL, StartTime, from, audioObj, evt, limitType )
global S

switch limitType
    case 'tap'
        stopOnset = audioObj.ReposRepos.Playback();
    case 'time'
        stopOnset = audioObj.ReposRepos.Playback(StartTime + EP.Data{evt,2} - S.PTB.anticipation);
end

Common.SendParPortMessage('ReposRepos'); % Parallel port

ER.AddEvent({EP.Data{evt,1} stopOnset-StartTime [] [] []})

if ~strcmp(EP.Data{evt-1,1},'StartTime')
    KL.GetQueue;
    results = Common.SequenceAnalyzer(EP.Data{evt-1,4}, S.Side, EP.Data{evt-1,3}, from, KL.EventCount, KL);
    from = KL.EventCount;
    ER.Data{evt-1,4} = results;
    disp(results)
end

switch EP.Data{evt+1,1}
    case 'Simple'
        PTBtimeLimit = stopOnset + EP.Data{evt,3} - audioObj.SimpleSimple.duration - S.PTB.anticipation;
    case {'Complex','Free'}
        PTBtimeLimit = stopOnset + EP.Data{evt,3} - audioObj.ComplexComplex.duration - S.PTB.anticipation;
    otherwise
        PTBtimeLimit = stopOnset + EP.Data{evt,3} - S.PTB.anticipation;
end


% The WHILELOOP below is a trick so we can use ESCAPE key to quit
% earlier.
keyCode = zeros(1,256);
secs = stopOnset;
while ~( keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII) || ( secs > PTBtimeLimit ) )
    [~, secs, keyCode] = KbCheck;
end

[ Exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
if Exit_flag
    return
end

if ~strcmp(EP.Data{evt+1,1},'StopTime')
    
    switch EP.Data{evt+1,1}
        case 'Simple'
            audioObj.SimpleSimple  .Playback(PTBtimeLimit);
            Common.SendParPortMessage('SimpleSimple');   % Parallel port
        case {'Complex','Free'}
            audioObj.ComplexComplex.Playback(PTBtimeLimit);
            Common.SendParPortMessage('ComplexComplex'); % Parallel port
        otherwise
            error('')
    end
    
end

end % function
