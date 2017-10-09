function [ EP ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement  = 'MRI';
    S.OperationMode = 'Acquisition';
    S.Sequence      = '';
end


%% Paradigme

switch S.OperationMode
    case 'Acquisition'
        SequenceDuration = 30; % secondes
        RestDuration     = 15;  % secondes
        NrBlocksSimple   = 10;
        NrBlocksComplex  = 10;
    case 'FastDebug'
        SequenceDuration = 5; % secondes
        RestDuration     = 2;  % secondes
        NrBlocksSimple   = 1;
        NrBlocksComplex  = 1;
    case 'RealisticDebug'
        SequenceDuration = 30; % secondes
        RestDuration     = 5;  % secondes
        NrBlocksSimple   = 1;
        NrBlocksComplex  = 1;
end

randomizeOrder = 1; % 0 or 1


%% Backend setup


switch randomizeOrder
    case 1
        BlockOrder = Common.Randomize01(NrBlocksSimple,NrBlocksComplex);
    case 0
        error('no randmization not coded yet !')
end


Paradigme = { 'Rest' RestDuration [] }; % initilaise the container

for n = 1:length(BlockOrder)
    
    if BlockOrder(n) % 1
        Paradigme  = [ Paradigme ; { 'Complex' SequenceDuration S.Sequence } ; { 'Rest' RestDuration [] } ]; %#ok<AGROW>
    else % 0
        Paradigme  = [ Paradigme ; { 'Simple'  SequenceDuration '5432' }     ; { 'Rest' RestDuration [] } ]; %#ok<AGROW>
    end
    
end


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' 'SequenceFingers(vect)' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] });

% --- Stim ----------------------------------------------------------------

for p = 1 : size(Paradigme,1)
    
    EP.AddPlanning({ Paradigme{p,1} NextOnset(EP) Paradigme{p,2} Paradigme{p,3} });
    
end

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] });


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
