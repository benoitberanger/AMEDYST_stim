function XY = XY
global S


%% Shortcut

from     = S.TaskData.OutRecorder.Data;
data     = S.TaskData.SR         .Data;
targetPx = S.TaskData.TargetBigCirclePosition;


%% Plot

XY = struct;

method = 1;

auc_deviation = [];
auc_direct    = [];

% Loop : plot curve for each trial
for trial = 1 : size(from,1)
    frame_start = from(trial,7);
    frame_stop  = from(trial,8);
    
    xy = data(frame_start:frame_stop,2:3);
    angle = from(trial,6)*pi/180; % degree to rad
    rotation_matrix = [cos(angle) -sin(angle); sin(angle) cos(angle)];
    xy = xy*rotation_matrix; % change referencial
    %     xy = xy/targetY; % normalize
    
    if from(trial,4) ~= 0 % deviation
        auc_deviation = [auc_deviation abs(trapz(xy(:,1),xy(:,2)))]; %#ok<AGROW>
    else % direct
        auc_direct    = [auc_direct abs(trapz(xy(:,1),xy(:,2)))]; %#ok<AGROW>
    end
    
    XY(method).TRIAL(trial).frame_start = frame_start;
    XY(method).TRIAL(trial).frame_stop  = frame_stop;
    XY(method).TRIAL(trial).xy          = xy;
    XY(method).TRIAL(trial).deviation   = from(trial,4);
    XY(method).TRIAL(trial).value       = from(trial,5);
    XY(method).TRIAL(trial).target      = from(trial,6);
    XY(method).TRIAL(trial).targetPx    = targetPx;
    XY(method).TRIAL(trial).auc         = abs(trapz(xy(:,1),xy(:,2)));
    XY(method).AUC.Deviation.vect       = auc_deviation;
    XY(method).AUC.Deviation.mean       = round(nanmean(auc_deviation));
    XY(method).AUC.Deviation.std        = round(nanstd(auc_deviation));
    XY(method).AUC.Direct.vect          = auc_direct;
    XY(method).AUC.Direct.mean          = round(nanmean(auc_direct));
    XY(method).AUC.Direct.std           = round(nanstd(auc_direct));
    
end

% fprintf('AUC Deviation : \n')
% disp(auc_deviation)
fprintf('mean AUC Deviation : %d \n', XY(method).AUC.Deviation.mean)
fprintf('std  AUC Deviation : %d \n', XY(method).AUC.Deviation.std )
% fprintf('AUC Direct : \n')
% disp(auc_direct)
fprintf('mean AUC Direct    : %d \n', XY(method).AUC.Direct.   mean)
fprintf('std  AUC Direct    : %d \n', XY(method).AUC.Direct.   std )


end % function
