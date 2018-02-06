function [ ER, RR, KL, SR, OutRecorder, InRecorder ] = PrepareRecorders( EP )
global S

%% Prepare event record

% Create
switch S.Task
    case 'SEQ'
        ER = EventRecorder( { 'event_name' , 'onset(s)' , 'durations(s)' , 'sequence_results' } , size(EP.Data,1) );
    case {'ADAPT_LowReward','ADAPT_HighReward'}
        ER = EventRecorder( EP.Header                                                           , size(EP.Data,1) );
end

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Response recorder

% Create
switch S.Task
    case 'SEQ'
        
        RR = EventRecorder( { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' } , 5000 ); % high arbitrary value : preallocation of memory
        
    case {'ADAPT_LowReward','ADAPT_HighReward'}
        
        RR = EventRecorder( EP.Header , 5000 );
        
        OutRecorder = SampleRecorder( { 'BlockNumber' 'Trial index', 'jitter duration (s)', 'Deviation (°)', 'Value[0-100]', 'Target angle (°)', 'frame_start', 'frame_stop', 'Reaction time OUT (ms)', 'Travel time OUT (ms)'} , 5000 );
        InRecorder  = SampleRecorder( { 'BlockNumber' 'Trial index', 'jitter duration (s)', 'Deviation (°)', 'Value[0-100]', 'Target angle (°)', 'frame_start', 'frame_stop', 'Reaction time IN (ms)' , 'Travel time IN (ms)' } , 5000 );
        
end

% Prepare
RR.AddStartTime( 'StartTime' , 0 );


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
