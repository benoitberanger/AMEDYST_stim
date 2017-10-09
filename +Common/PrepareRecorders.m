function [ ER, RR, KL ] = PrepareRecorders( EP )
global S

%% Prepare event record

% Create
ER = EventRecorder( { 'event_name' , 'onset(s)' , 'durations(s)' , 'sequence_results' , 'voice_data' } , size(EP.Data,1) );

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Response recorder

% Create
RR = EventRecorder( { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' } , 5000 ); % high arbitrary value : preallocation of memory

% Prepare
RR.AddEvent( { 'StartTime' , 0 , 0 , [] } );


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

KL = KbLogger( ...
    [ struct2array(S.Parameters.Keybinds) S.Parameters.Fingers.All ] ,...
    [ KbName(struct2array(S.Parameters.Keybinds)) S.Parameters.Fingers.Names ] );

% Start recording events
KL.Start;

end % function
