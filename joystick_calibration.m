function joystick_calibration(hObject, eventData)
handles = guidata(hObject);

lim = 2^15; % joystick ADC is int16

npoint = 1e5; % vector length for calibration (just for pre-allocation)

% Initialize joystick
joymex2('open',0);

% Open figure
f = figure('Name',mfilename,'NumberTitle','off');


%% Raw

a(1) = subplot(1,2,1);
hold(a(1),'on')
axis(a(1), 'equal')

raw_rect = rectangle(a(1),'Position', [-lim -lim lim*2 lim*2], 'LineWidth', 4);
raw_pointer_plot = plot(a(1), 0, 0, 'x');
raw_history_pos = nan(npoint,2);
raw_history_plot = plot(a(1), raw_history_pos(:,1), raw_history_pos(:,2));


%% Calibrated

a(2) = subplot(1,2,2);
hold(a(2),'on')
axis(a(2), 'equal')

cal_rect = rectangle(a(2),'Position', [-1 -1 2 2], 'LineWidth', 4);
cal_pointer_plot = plot(a(2), 0, 0, 'x');
cal_history_pos = nan(npoint,2);
cal_history_plot = plot(a(2), cal_history_pos(:,1), cal_history_pos(:,2));


%% Loop

KbName('UnifyKeyNames');
ESCAPE = KbName('ESCAPE');

count = 0;
while 1
    
    count = count + 1;
    
    % Query postion and button state of joystick 0
    data = joymex2('query',0);
    
    raw_x = double( data.axes(1));
    raw_y = double(-data.axes(2));
    raw_pointer_plot.XData = raw_x;
    raw_pointer_plot.YData = raw_y;
    raw_history_plot.XData(count) = raw_x;
    raw_history_plot.YData(count) = raw_y;
    
    min_x = min(raw_history_plot.XData(1:count));
    max_x = max(raw_history_plot.XData(1:count));
    min_y = min(raw_history_plot.YData(1:count));
    max_y = max(raw_history_plot.YData(1:count));
    
    if raw_x > 0
        cal_x =  raw_x/max_x;
    else
        cal_x = -raw_x/min_x;
    end
    if raw_y > 0
        cal_y =  raw_y/max_y;
    else
        cal_y = -raw_y/min_y;
    end
    cal_pointer_plot.XData = cal_x;
    cal_pointer_plot.YData = cal_y;
    cal_history_plot.XData(count) = cal_x;
    cal_history_plot.YData(count) = cal_y;
    
    fprintf('raw = %6d %6d   //   cal = %4.2f %4.2f \n', raw_x, raw_y, cal_x, cal_y)
    
    drawnow
    
    [keyIsDown,~, keyCode] = KbCheck();
    if keyIsDown
        if keyCode(ESCAPE)
            break
        end
    end
    
end



%% Cleanup

clear joymex2
close(f)


%% Save x y min max

set(handles.edit_xmin_ymin_xmax_ymax,'String', num2str([min_x min_y max_x max_y]))


end
