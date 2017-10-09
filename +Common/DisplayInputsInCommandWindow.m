function [ Exit_flag, StopTime ] = DisplayInputsInCommandWindow( EP, ER, RR, evt, StartTime, audioObj, limitType, limitValue )
global S


% 5
% 4
% 3
% 2
% 2 <-
% 3 <-
% 4 <-
% 5

%% Ouput var

Exit_flag = 0;
StopTime  = [];


%% Initialize the count-by-difference

sequence_str = EP.Data{evt,4}; % sequence

next_input = sequence_str(1); % initilization

switch S.Side
    case 'Left'
        Side = S.Parameters.Fingers.Left; % shortcut
    case 'Right'
        Side = S.Parameters.Fingers.Right; % shortcut
end

KbVect_prev = zeros(size(Side));


%% Loop

% Initialization for the whileloop
secs = GetSecs;
tap  = 0;
switch limitType
    case 'tap'
        condition = tap  < limitValue;
    case 'time'
        condition = secs < limitValue;
end

% Need wake up ?
switch S.Task
    case {'Training', 'SpeedTest', 'DualTask_Complex', 'DualTask_Simple'}
        wakeup = 1;
        wakeupTime = 5; % seconds
        lastWakeup = secs;
    otherwise
        wakeup = 0;
end

good = 0;
bad  = 0;
while condition
    
    [keyIsDown, secs, keyCode] = KbCheck;
    
    % Compare last input with current unpur
    KbVect_curr = keyCode(Side);
    KbVect_diff = KbVect_curr - KbVect_prev;
    KbVect_prev = KbVect_curr;
    new_input   = find(KbVect_diff==1);
    
    % New value
    if ~isempty(new_input) && isscalar(new_input)
        
%         Common.SendParPortMessage(['finger_' new_input]); % Parallel port
        
        if new_input == str2double(next_input)
            fprintf('%d\n',new_input)
            sequence_str = circshift(sequence_str,[0 -1]);
            next_input = sequence_str(1);
            good = good + 1;
        else
            fprintf('%d <-\n',new_input)
            good = 0; % reset the counter
            bad  = bad + 1;
        end
        tap = tap+1;
        
        if wakeup
            lastWakeup = secs;
        end
        
    end
    
    if wakeup
        if lastWakeup + wakeupTime < secs
            
            
            switch S.Task
                
                case 'Training'
                    
                    % Wakeup
                    onset = audioObj.rooster.Playback();
                    RR.AddEvent({'Wakeup' onset-StartTime [] 'rooster.wav'});
                    Common.SendParPortMessage('WakeUp'); % Parallel port
                    lastWakeup = onset;
                    
                        % Recall of block's instructions
                        switch EP.Data{evt,1}
                            case 'Simple'
                                tag = 'SimpleSimple';
                            case 'Complex'
                                tag = 'ComplexComplex';
                        end
                        onset = audioObj.(tag).Playback();
                        Common.SendParPortMessage(tag); % Parallel port
                        RR.AddEvent({'Recall' onset-StartTime [] [tag '.wav']});
                   
                    
                otherwise
                    
                    % if participant doesn't tap at all, we assume he didn't hear the instructions => rooster sound + instructions; 
                    % if participant tapped in the past but stopped tapping withtin the bloxk, we assumed he fell asleep => we wake him up during training (we need these data) but not during the tests
                    if tap == 0
                        
                        % Wakeup
                        onset = audioObj.rooster.Playback();
                        Common.SendParPortMessage('WakeUp'); % Parallel port
                        RR.AddEvent({'Wakeup' onset-StartTime [] 'rooster.wav'});
                        lastWakeup = onset;
                        
                        % Recall of block's instructions
                        switch EP.Data{evt,1}
                            case 'Simple'
                                tag = 'SimpleSimple';
                            case 'Complex'
                                tag = 'ComplexComplex';
                        end
                        onset = audioObj.(tag).Playback();
                        Common.SendParPortMessage(tag); % Parallel port
                        RR.AddEvent({'Recall' onset-StartTime [] [tag '.wav']});
                    end
                    
            end
            
            
            
            
        end
    end
    
    % Escape ?
    if keyIsDown
        [ Exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
        if Exit_flag
            return
        end
    end
    
    % Refresh condition
    switch limitType
        
        case 'tap'
            if limitValue == Inf
                if good == EP.Data{evt,3} * length(sequence_str)
                    condition = 0;
                end
            else
                condition = tap  < limitValue;
            end
            
        case 'time'
            condition = secs < limitValue;
            
    end
    
end % while

end % function
