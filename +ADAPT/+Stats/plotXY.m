function plotXY
global S


%% Shortcut

XY = S.Stats.XY;

sortedValues = sort(S.TaskData.Parameters.Values);
Colors = jet(length(sortedValues));


%% Plot

method = 1;

% Polar coordinates
f = figure(20+method);
set(f,'NumberTitle','off');
set(f,'Name','Plot Y(X) in untilted referiential (like target=0°) ');
ax(1) = subplot(2,1,1);
hold(ax(1), 'on')
ax(2) = subplot(2,1,2);
hold(ax(2), 'on')

% Loop : plot curve for each trial
for trial = 1 : length(XY(method).TRIAL)
    
    xy        = XY(method).TRIAL(trial).xy;
    % target    = XY(method).TRIAL(trial).target;
    deviation = XY(method).TRIAL(trial).deviation;
    targetPx  = XY(method).TRIAL(trial).targetPx;
    value     = XY(method).TRIAL(trial).value;
    color     = Colors(value==sortedValues,:);
    
    if deviation ~= 0 % deviation
        axx = ax(1);
    else % direct
        axx = ax(2);
    end
    plot( axx, xy(:,1), xy(:,2), 'DisplayName', sprintf('Value - %d',value), 'Color', color);
    
    
end

% ideal trajectorty
plot( ax(1), [0 targetPx], [0 0], 'k', 'LineWidth', 2, 'DisplayName', 'optimal');
plot( ax(2), [0 targetPx], [0 0], 'k', 'LineWidth', 2, 'DisplayName', 'optimal');

title(ax(1),'Deviation')
title(ax(2),'Direct')

axis(ax(1), 'tight')
axis(ax(2), 'tight')

linkaxes(ax,'xy')

xlabel(ax(1),'X (pixels)')
xlabel(ax(2),'X (pixels)')
ylabel(ax(1),'Y (pixels)')
ylabel(ax(2),'Y (pixels)')


end % function
