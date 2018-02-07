function [ EP, Parameters ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement  = 'MRI';
    S.OperationMode = 'Acquisition';
    S.LowReward     = 06.4;
    S.HighReward    = 32.0;
    S.Task          = 'ADAPT_HighReward';
end

switch S.Task
    case 'ADAPT_HighReward'
        TotalMaxReward = S.HighReward;
    case 'ADAPT_LowReward'
        TotalMaxReward = S.LowReward;
    otherwise
        error('task ?')
end

%% Paradigme

Parameters.TrialMaxDuration            = 5.0; % seconds
Parameters.TimeSpentOnTargetToValidate = 0.5; % seconds
Parameters.MinPauseBetweenTrials       = 0.5; % seconds
Parameters.MaxPauseBetweenTrials       = 1.5; % seconds
Parameters.TimeWaitReward              = 0.5; % seconds
Parameters.RewardDisplayTime           = 1.0; % seconds

Parameters.TargetAngles                =         [20 60 120 160]       ;
Parameters.Values                      = Shuffle([0  1  2   3  ]/3 * 100); % Association of 1 TargetAngle with 1 Value (randomized for each run)

randSign = sign(rand-0.5);

switch S.OperationMode
    
    case 'Acquisition'
        
        Paradigm = {
            'Direct_Pre'  0           32
            'Deviation'   randSign*45 64
            'Direct_Post' 0           32
            };
        
    case 'FastDebug'
        
        Paradigm = {
            'Direct_Pre'  0           4
            'Deviation'   randSign*45 4
            'Direct_Post' 0           4
            };
        
    case 'RealisticDebug'
        
        Paradigm = {
            'Direct_Pre'  0           8
            'Deviation'   randSign*45 8
            'Direct_Post' 0           8
            };
        
end

% Some values...
NrTrials = sum(cell2mat(Paradigm(:,3)));

%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)', 'Block#', 'Trial#', 'Deviation(°)', 'Target angle (°)', 'Variable pause duration (s)', 'Probability of reward (%)', 'is rewarded (0/1)'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------

% Shuffle the list of angles
angleList = Shuffle(Parameters.TargetAngles);

trial_counter = 0;

for block = 1 : size(Paradigm,1)
    
    for trial_idx_in_block = 1 : Paradigm{block,3}
        
        trial_counter = trial_counter + 1;
        
        % If angleList is empty, generate a new one
        if isempty(angleList)
            angleList = Shuffle(Parameters.TargetAngles);
        end
        
        pauseJitter = Parameters.MinPauseBetweenTrials + (Parameters.MaxPauseBetweenTrials-Parameters.MinPauseBetweenTrials)*rand; % in seconds (s), random value beween [a;b] interval
        
        value = Parameters.Values(angleList(end)==Parameters.TargetAngles); % Fetch the Value associated with this TargetAngle
        
        EP.AddPlanning({ Paradigm{block,1} NextOnset(EP) Parameters.TrialMaxDuration block trial_counter Paradigm{block,2}   angleList(end) pauseJitter value double(rand*100<value)});
        
        angleList(end) = []; % Remove the last angle used
        
    end
    
end

% --- Stop ----------------------------------------------------------------

EP.AddStopTime('StopTime',NextOnset(EP));


%% Compute gain when rewarded

NrRewardPerValue = Parameters.Values/100 * NrTrials/length(Parameters.Values);
UnitGain         = TotalMaxReward / sum(NrRewardPerValue);
TotalReward      = sum(cell2mat(EP.Data(2:end-1,10))) * UnitGain;
fprintf('UnitGain for this run     : %g € \n', UnitGain);
fprintf('Total reward for this run : %g € \n', TotalReward);

Parameters.UnitGain    = UnitGain;
Parameters.TotalReward = TotalReward;


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
