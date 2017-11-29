function [ EP, Parameters ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement    = 'MRI';
    S.OperationMode   = 'Acquisition';
end


%% Paradigme

Parameters.TrialMaxDuration            = 5; % seconds
Parameters.TimeSpentOnTargetToValidate = 0.5; % seconds
Parameters.MinPauseBetweenTrials       = 0.5; % seconds
Parameters.MaxPaiseBetweenTrials       = 0.5; % seconds

switch S.OperationMode
    
    case 'Acquisition'
        
        Paradigm = [
            0  30
            35 60
            0  30
            ];
        
    case 'FastDebug'
        
        Paradigm = [
            0  1
            35 1
            0  1
            ];
        
    case 'RealisticDebug'
        
        Paradigm = [
            0  5
            35 5
            0  5
            ];
        
end


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' 'NrTrials' 'Deviation(°)'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] []});

% --- Stim ----------------------------------------------------------------

for p = 1 : size(Paradigm,1)
    
    if  Paradigm(p,1) == 0
        blockName = 'Direct';
    else
        blockName = 'Deviation';
    end
    EP.AddPlanning({ blockName NextOnset(EP) Parameters.TrialMaxDuration*Paradigm(p,2) Paradigm(p,2) Paradigm(p,1) });
    
end

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] []});


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end

end % function
