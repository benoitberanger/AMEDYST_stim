function [ EP ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement    = 'MRI';
    S.OperationMode   = 'Acquisition';
end


%% Paradigme

switch S.OperationMode
    case 'Acquisition'
        
    case 'FastDebug'
        
    case 'RealisticDebug'
        
end


%% Backend setup


Paradigm = { '' 0 0 0 };


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' 'SequenceFingers(vect)' 'TapFrequency(Hz)'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] []});

% --- Stim ----------------------------------------------------------------

for p = 1 : size(Paradigm,1)
    
    EP.AddPlanning({ Paradigm{p,1} NextOnset(EP) Paradigm{p,2} Paradigm{p,3} Paradigm{p,4}});
    
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
