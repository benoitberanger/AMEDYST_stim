function plotTheta
global S


%% Shortcut

THETA = S.Stats.THETA;

sortedValues = sort(S.TaskData.Parameters.Values);
Colors = jet(length(sortedValues));


%% Plot

for method = 1 : 3
    
    % Polar coordinates
    f = figure(10+method);
    set(f,'NumberTitle','off');
    switch method
        case 1
            set(f,'Name','Plot Theta(t) ''normalized'' from 0 to 1, all trial');
        case 2
            set(f,'Name','Plot Theta(t) ''normalized'' from 1, Cut @ Theta(t) ~= Theta(0)');
        case 3
            set(f,'Name','Plot Theta(t) ''normalized'' from 1, only TravelTime, cut after ReactionTime');
    end
    ax(1) = subplot(2,1,1);
    hold(ax(1), 'on')
    ax(2) = subplot(2,1,2);
    hold(ax(2), 'on')
    
    % Loop : plot curve for each trial
    for trial = 1 : length(THETA(method).TRIAL)
        
        max_time  = THETA(method).TRIAL(trial).max_time;
        time      = THETA(method).TRIAL(trial).time;
        theta     = THETA(method).TRIAL(trial).theta;
        % target    = THETA(method).TRIAL(trial).target;
        deviation = THETA(method).TRIAL(trial).deviation;
        value     = THETA(method).TRIAL(trial).value;
        color     = Colors(value==sortedValues,:);
        
        if deviation ~= 0 % deviation
            axx = ax(1);
        else % direct
            axx = ax(2);
        end
        plot( axx, time, theta, 'DisplayName', sprintf('Value - %d',value), 'Color', color)
        
    end
    
    % Plot limit
    
    limit = 5; % percentage (%)
    
    plot( ax(1), [0 max_time], [1 1]*(1+limit/100), 'k:', 'DisplayName', '+5%');
    plot( ax(1), [0 max_time], [1 1]*(1-limit/100), 'k:', 'DisplayName', '-5%');
    
    plot( ax(2), [0 max_time], [1 1]*(1+limit/100), 'k:', 'DisplayName', '+5%');
    plot( ax(2), [0 max_time], [1 1]*(1-limit/100), 'k:', 'DisplayName', '-5%');
    
    title(ax(1),'Deviation')
    title(ax(2),'Direct')
    
    axis(ax(1), 'tight')
    axis(ax(2), 'tight')
    
    linkaxes(ax,'xy')
    
    xlabel(ax(1),'time (s)')
    xlabel(ax(2),'time (s)')
    ylabel(ax(1),'normalized unit')
    ylabel(ax(2),'normalized unit')
    
end


end % function
