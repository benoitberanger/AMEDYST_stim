function plotTheta
global S

%% Shortcut

from = S.TaskData.OutRecorder.Data;
data = S.TaskData.SR         .Data;


%% Plot

for fig = 1 : 3
    
    % Polar coordinates
    figure(10+fig)
    ax(1) = subplot(2,1,1);
    hold(ax(1), 'on')
    ax(2) = subplot(2,1,2);
    hold(ax(2), 'on')
    
    max_time = 0;
    
    % Loop : plot curve for each trial
    for trial = 1 : size(from,1)
        frame_start = from(trial,6);
        frame_stop  = from(trial,7);
        
        theta = data(frame_start:frame_stop,5); % raw                           :  thetha(t)
        theta = theta - data(frame_start,5);    % offcet, the curve start at 0° :  thetha(t) - thetha(0)
        theta = theta/theta(end);               % normalize, from 0 to 1        : (thetha(t) - thetha(0)) / ( theta(end) - thetha(0) )
        
        % Extract t
        time = data(frame_start:frame_stop,1)-data(frame_start,1); % time, in sedonds
        
        % Different methods to visualize the data :
        switch fig
            
            case 1 % Plot Theta(t) 'normalized' from 1, all trial
                
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
                idx_theta_toKeep = time*1000>=from(trial,8); % warning : here RT is in millisecond (ms), but time is in seconds (s)
                idx_t_toCut      = find(idx_theta_toKeep);
                
                % Cut t & normalize
                time = time(idx_theta_toKeep)-time(idx_t_toCut(1));
                max_time = max(max(time),max_time);
                
                % Cut Theta
                theta = theta(idx_theta_toKeep);
                
        end
        
        if from(trial,4) ~= 0 % deviation
            plot( ax(1), time, theta, 'DisplayName',sprintf('Deviation - %d',from(trial,5)));
        else % direct
            plot( ax(2), time, theta, 'DisplayName',sprintf('Direct - %d',from(trial,5)));
        end
        
    end
    
    % Plot limit
    
    limit = 5; % percentage (%)
    
    plot( ax(1), [0 max_time], [1 1]*(1+limit/100), 'k:');
    plot( ax(1), [0 max_time], [1 1]*(1-limit/100), 'k:');
    
    plot( ax(2), [0 max_time], [1 1]*(1+limit/100), 'k:');
    plot( ax(2), [0 max_time], [1 1]*(1-limit/100), 'k:');
    
    title(ax(1),'Deviation')
    title(ax(2),'Direct')
    
    axis(ax(1), 'tight')
    axis(ax(2), 'tight')
    
    linkaxes(ax,'xy')
    
end

end % function
