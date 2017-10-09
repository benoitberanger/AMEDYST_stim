function TaskData = EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime )
global S

%% End of stimulation

% EventRecorder
% if size(EP.Data,2)>3
%     EP.Data(:,4:end) = [];
% end
ER.ClearEmptyEvents;
ER.ComputeDurations;
ER.BuildGraph;
TaskData.ER = ER;

switch S.Task
    case {'Familiarization','Training', 'SpeedTest'}
        EP.Data = {};
        EP.Data(:,1:3) = ER.Data(:,1:3);
        EP.BuildGraph;
        TaskData.EP = EP;
end

% Response Recorder
RR.ClearEmptyEvents;
RR.ComputeDurations;
% RR.MakeBlocks;
RR.BuildGraph;
TaskData.RR = RR;

% KbLogger
KL.GetQueue;
KL.Stop;
switch S.OperationMode
    case 'Acquisition'
    case 'FastDebug'
        TR = 2.005; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ) ; % nb of volumes for the estimated time of stimulation
        KL.GenerateMRITrigger( TR , nbVolumes + 2 , StartTime );
    case 'RealisticDebug'
        TR = 2.005; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ); % nb of volumes for the estimated time of stimulation
        KL.GenerateMRITrigger( TR , nbVolumes + 2, StartTime );
    otherwise
end
KL.ScaleTime;
KL.ComputeDurations;
KL.BuildGraph;
TaskData.KL = KL;

% Save some values
TaskData.StartTime = StartTime;
TaskData.StopTime  = StopTime;


%% Send infos to base workspace

assignin('base','EP',EP)
assignin('base','ER',ER)
assignin('base','RR',RR)
assignin('base','KL',KL)

assignin('base','TaskData',TaskData)


%% Close all audio devices

% Close the audio device
% PsychPortAudio('Close');


%% Close parallel port

switch S.ParPort
    
    case 'On'
        CloseParPort;
        
    case 'Off'
        
end


%% Diagnotic

switch S.OperationMode
    
    case 'Acquisition'
        
    case 'FastDebug'
        plotDelay
        
    case 'RealisticDebug'
        plotDelay
        
end

end % function
