function plotXY
global S


%% Shortcut

from    = S.TaskData.OutRecorder.Data;
data    = S.TaskData.SR         .Data;
targetY = S.TaskData.TargetBigCirclePosition;


%% Plot

fig = 1;

% Polar coordinates
figure(20+fig)
ax(1) = subplot(2,1,1);
hold(ax(1), 'on')
ax(2) = subplot(2,1,2);
hold(ax(2), 'on')

% Loop : plot curve for each trial
for trial = 1 : size(from,1)
    frame_start = from(trial,6);
    frame_stop  = from(trial,7);
    
    xy = data(frame_start:frame_stop,2:3);
    angle = from(trial,5)*pi/180; % degree to rad
    rotation_matrix = [cos(angle) -sin(angle); sin(angle) cos(angle)];
    xy = xy*rotation_matrix; % change referencial
    xy = xy/targetY; % ,normalize
    
    if from(trial,4) ~= 0 % deviation
        plot( ax(1), xy(:,1), xy(:,2), 'DisplayName',sprintf('Deviation - %d',from(trial,5)));
    else % direct
        plot( ax(2), xy(:,1), xy(:,2), 'DisplayName',sprintf('Direct - %d',from(trial,5)));
    end
    
end

% ideal trajectorty
plot( ax(1), [0 1], [0 0], 'k', 'LineWidth',2);
plot( ax(2), [0 1], [0 0], 'k', 'LineWidth',2);

title(ax(1),'Deviation')
title(ax(2),'Direct')

axis(ax(1), 'tight')
axis(ax(2), 'tight')

linkaxes(ax,'xy')

xlabel(ax(1),'normalized unit')
xlabel(ax(2),'normalized unit')
ylabel(ax(1),'normalized unit')
ylabel(ax(2),'normalized unit')


end % function
