function THETA = Theta
global S


%% Shortcut

from = S.TaskData.OutRecorder.Data;
data = S.TaskData.SR         .Data;


%% Plot

THETA = struct;

for method = 1 : 3
    
    max_time = 0;
    
    % Loop : plot curve for each trial
    for trial = 1 : size(from,1)
        frame_start = from(trial,7);
        frame_stop  = from(trial,8);
        
        theta = data(frame_start:frame_stop,5); % raw                           :  thetha(t)
        theta = theta - data(frame_start,5);    % offcet, the curve start at 0° :  thetha(t) - thetha(0)
        theta = theta/theta(end);               % normalize, from 0 to 1        : (thetha(t) - thetha(0)) / ( theta(end) - thetha(0) )
        
        % Extract t
        time = data(frame_start:frame_stop,1)-data(frame_start,1); % time, in sedonds
        
        % Different methods to visualize the data :
        switch method
            
            case 1 % Plot Theta(t) 'normalized' from 0 to 1, all trial
                
                max_time = max(max(time),max_time);
                
            case 2 % Plot Theta(t) 'normalized' from 1, Cut @ Theta(t) ~= Theta(0)
                
                % Cut curves, start when Theta(t) ~= Theta(0)
                % WARNING : if the trajectory is PERFECT (very unlikle) such as Theta(t) = constant = Theta-target, then this plot will not work
                idx_theta_toKeep = theta~=0;
                idx_t_toCut      = find(theta~=0);
                
                % Cut t & normalize
                time = time(idx_theta_toKeep)-time(idx_t_toCut(1));
                max_time = max(max(time),max_time);
                
                % Cut Theta
                theta = theta(idx_theta_toKeep);
                
            case 3 % Plot Theta(t) 'normalized' from 1, only TravelTime, cut after ReactionTime
                
                % Cut curves, start after RT
                idx_theta_toKeep = time*1000>=from(trial,9); % warning : here RT is in millisecond (ms), but time is in seconds (s)
                idx_t_toCut      = find(idx_theta_toKeep);
                
                % Cut t & normalize
                time = time(idx_theta_toKeep)-time(idx_t_toCut(1));
                max_time = max(max(time),max_time);
                
                % Cut Theta
                theta = theta(idx_theta_toKeep);
                
        end
        
        THETA(method).TRIAL(trial).frame_start = frame_start;
        THETA(method).TRIAL(trial).frame_stop  = frame_stop;
        THETA(method).TRIAL(trial).max_time    = max_time;
        THETA(method).TRIAL(trial).time        = time;
        THETA(method).TRIAL(trial).theta       = theta;
        THETA(method).TRIAL(trial).deviation   = from(trial,4);
        THETA(method).TRIAL(trial).value       = from(trial,5);
        THETA(method).TRIAL(trial).target      = from(trial,6);
        THETA(method).TRIAL(trial).block       = from(trial,1);
        
    end
    
    
end


end % function
