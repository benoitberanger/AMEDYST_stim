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
    
    for block = 1 : 3
        ax(block) = subplot(3,1,block); %#ok<AGROW>
        hold(ax(block), 'on')
    end
    
    % Loop : plot curve for each trial
    for trial = 1 : length(THETA(method).TRIAL)
        
        max_time  = THETA(method).TRIAL(trial).max_time;
        time      = THETA(method).TRIAL(trial).time;
        theta     = THETA(method).TRIAL(trial).theta;
        % target    = THETA(method).TRIAL(trial).target;
        % deviation = THETA(method).TRIAL(trial).deviation;
        value     = THETA(method).TRIAL(trial).value;
        color     = Colors(value==sortedValues,:);
        block     = THETA(method).TRIAL(trial).block;
        
        plot( ax(block), time, theta, 'DisplayName', sprintf('Value - %d',value), 'Color', color)
        
    end
    
    % Plot limit
    
    limit = 5; % percentage (%)
    
    for block = 1 : 3
        plot  (ax(block), [0 max_time], [1 1]*(1+limit/100), 'k:', 'DisplayName', '+5%');
        plot  (ax(block), [0 max_time], [1 1]*(1-limit/100), 'k:', 'DisplayName', '-5%');
        axis  (ax(block), 'tight')
        xlabel(ax(block), 'time (s)')
        ylabel(ax(block), 'normalized unit')
    end
    
    linkaxes(ax,'xy')
    
    title(ax(1),'Deviation-Pre')
    title(ax(2),'Direct')
    title(ax(3),'Deviation-Post')
    
end


end % function
