function [ ER, RR, KL, SR, OutRecorder, InRecorder ] = PrepareRecorders( EP )
global S

%% Prepare event record

% Create
switch S.Task
    case 'SEQ'
        ER = EventRecorder( { 'event_name' , 'onset(s)' , 'durations(s)' , 'sequence_results'                  } , size(EP.Data,1) );
    case 'ADAPT'
        ER = EventRecorder( { 'event_name' , 'onset(s)' , 'durations(s)' , 'NrTrials'         , 'Deviation(°)' } , size(EP.Data,1) );
    case 'EyelinkCalibration'
end

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Response recorder

RR = EventRecorder( { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' } , 5000 ); % high arbitrary value : preallocation of memory

% Prepare
RR.AddStartTime( 'StartTime' , 0 );

% Create
switch S.Task
    case 'SEQ'
    case 'ADAPT'
        %         RR = EventRecorder( { 'event_name' , 'onset(s)' , 'duration(s)' , 'Trial index', 'jitter duration (s)', 'Deviation(°)', 'Step', 'frame_start' , 'frame_stop'  } , 5000 );
        %         RR = EventRecorder( { 'Trial index', 'jitter duration (s)', 'Deviation(°)', 'Step', 'frame_start', 'frame_stop', 'Reaction time OUT (s)', 'Travel time OUT (s)', 'Reaction time IN (s)', 'Travel time IN (s)' } , 5000 );
        OutRecorder = EventRecorder( { 'Trial index', 'jitter duration (s)', 'Deviation (°)', 'Target angle (°)', 'frame_start', 'frame_stop', 'Reaction time OUT (s)', 'Travel time OUT (s)'} , 5000 );
        InRecorder  = EventRecorder( { 'Trial index', 'jitter duration (s)', 'Deviation (°)', 'Target angle (°)', 'frame_start', 'frame_stop', 'Reaction time IN (s)' , 'Travel time IN (s)' } , 5000 );
end


%% Sample recorder

SR = SampleRecorder( { 'time (s)', 'X (pixels)', 'Y (pixels)', 'R (pixels)', 'Theta (°)' } , EP.Data{end,2}*S.PTB.FPS*1.20 ); % ( duration of the task +20% )


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

KL = KbLogger( ...
    [ struct2array(S.Parameters.Keybinds) S.Parameters.Fingers.All ] ,...
    [ KbName(struct2array(S.Parameters.Keybinds)) S.Parameters.Fingers.Names ] );

% Start recording events
KL.Start;


end % function
