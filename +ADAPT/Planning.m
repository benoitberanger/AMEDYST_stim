function [ EP, Parameters ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement  = 'MRI';
    S.OperationMode = 'Acquisition';
    S.LowReward     = 06.4;
    S.HighReward    = 32.0;
    S.Task          = 'ADAPT_HighReward';
    S.DeviationSign = '+';
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

% Jitter
Parameters.MinPauseBetweenTrials       = 0.5; % seconds
Parameters.MaxPauseBetweenTrials       = 1.5; % seconds

% Show reward probability
Parameters.RewardProbabilityDuration   = 1.0; % seconds

Parameters.PausePreMotor               = 0.5; % seconds

% Move cursor
Parameters.TrialMaxDuration            = 4.0; % seconds
Parameters.TimeSpentOnTargetToValidate = 0.5; % seconds

Parameters.PausePostMotor              = 0.5; % seconds

% Show real reward
Parameters.ShowRewardDuration          = 1.0; % seconds


Parameters.TargetAngles                = [20 60 120 160]        ;
Parameters.Values                      = [0  1  2   3  ]/3 * 100;

switch S.DeviationSign
    case '+'
        Sign = 1;
    case '-'
        Sign = -1;
    otherwise
        error('DeviationSign error')
end

switch S.OperationMode
    
    case 'Acquisition'
        
        Paradigm = {
            'Direct_Pre'  0       32
            'Deviation'   Sign*45 64
            'Direct_Post' 0       32
            };
        
    case 'FastDebug'
        
        Paradigm = {
            'Direct_Pre'  0       4
            'Deviation'   Sign*45 4
            'Direct_Post' 0       4
            };
        
    case 'RealisticDebug'
        
        Paradigm = {
            'Direct_Pre'  0       32
            'Deviation'   Sign*45 64
            'Direct_Post' 0       32
            };
        
end


% Some values...
NrTrials  = sum(cell2mat(Paradigm(:,3)));
NrTargets = length(Parameters.TargetAngles);
NrValues  = length(Parameters.Values);


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)', 'Block#', 'Trial#', 'Deviation(°)', 'Target angle (°)', 'Variable pause duration (s)', 'Probability of reward (%)', 'is rewarded (0/1)'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------

trial_counter = 0;

for block = 1 : size(Paradigm,1)
    
    % For each block, counterbalance Targets-Values
    
    % Some values... per block
    NrTrialsPerBlock  = Paradigm{block,3};
    
    % Counter-banlanced randomization of Vales per Targets
    
    NrValuesPerTarget = NrTrialsPerBlock / NrTargets / NrValues;
    
    if NrValuesPerTarget < 1 % in Debug mode, it an happen, because of very few trials
        NrValuesPerTarget = 1;
    end
    
    LinkTargetValue = nan(NrTrialsPerBlock/NrTargets, NrTargets); % pre-allocation
    
    if NrValuesPerTarget == 1
        LinkTargetValue = Common.ShuffleN( Parameters.Values, NrValuesPerTarget );
    else
        for target = 1 : NrTargets
            LinkTargetValue(:, target) = Common.ShuffleN( Parameters.Values, NrValuesPerTarget );
        end
    end
    
    % Shuffle the list of angles
    angleList = Shuffle( 1 : NrTargets );
    
    link_counter = 1;
    
    for trial_idx_in_block = 1 : Paradigm{block,3}
        
        trial_counter = trial_counter + 1;
        
        % If angleList is empty, generate a new one
        if isempty(angleList)
            angleList = Shuffle( 1 : NrTargets );
            link_counter = link_counter + 1;
        end
        
        pauseJitter = Parameters.MinPauseBetweenTrials + (Parameters.MaxPauseBetweenTrials-Parameters.MinPauseBetweenTrials)*rand; % in seconds (s), random value beween [a;b] interval
        
        value = LinkTargetValue( link_counter , angleList(end) ); % Fetch the Value associated with this TargetAngle
        
        trialDuration = pauseJitter + Parameters.RewardProbabilityDuration + Parameters.RewardProbabilityDuration + Parameters.PausePreMotor + Parameters.TrialMaxDuration * 2 + Parameters.PausePostMotor + Parameters.ShowRewardDuration;
        
        EP.AddPlanning({ Paradigm{block,1} NextOnset(EP) trialDuration block trial_counter Paradigm{block,2}  Parameters.TargetAngles(angleList(end)) pauseJitter value double(rand*100<value)});
        
        angleList(end) = []; % Remove the last angle used
        
    end
    
end

% --- Stop ----------------------------------------------------------------

EP.AddStopTime('StopTime',NextOnset(EP));


%% Check counter-balance design

data = EP.Data;

for block = 1 : 3
    
    % Block name
    switch block
        case 1
            name = 'Direct_Pre';
        case 2
            name = 'Deviation';
        case 3
            name = 'Direct_Post';
        otherwise
            error('block ?')
    end % switch
    
    % Fetch data in the current block
    block_idx     = strcmp(data(:,1),name);
    data_in_block = cell2mat(data( block_idx , 2:end ));
    
    for target  = 1 : NrTargets
        
        taget_idx =  Parameters.TargetAngles(target) == data_in_block(:,EP.Get('Target')-1) ;
        
        vales_target = data_in_block(taget_idx,EP.Get('Probability')-1);
        
        valesCountVect = nan(NrValues,1);
        
        for value = 1 : NrValues
            valesCountVect(value) = sum(vales_target == Parameters.Values(value));
        end
        
        if sum(diff(valesCountVect)) > 0
            warning('error in counter-balance of Target-ProbaValues (dont worry in FastDebug)')
        end
        
    end
    
end


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
