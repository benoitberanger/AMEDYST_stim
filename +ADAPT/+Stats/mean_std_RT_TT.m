function [direct, deviation] = mean_std_RT_TT
global S

%% Shortcut

from = S.TaskData.OutRecorder.Data;


%% Compute mean & std for ReactionTime and TravelTime


% Direct

direct.idx     = find(from(:,4) == 0);

direct.RT_vect = from(direct.idx,8);
direct.RT_mean = round(mean(direct.RT_vect));
direct.RT_std  = round(std(direct.RT_vect));

direct.TT_vect = from(direct.idx,9);
direct.TT_mean = round(mean(direct.TT_vect));
direct.TT_std  = round(std(direct.TT_vect));


% Deviation

deviation.idx     = find(from(:,4) ~= 0);

deviation.RT_vect = from(deviation.idx,8);
deviation.RT_mean = round(mean(deviation.RT_vect));
deviation.RT_std  = round(std(deviation.RT_vect));

deviation.TT_vect = from(deviation.idx,9);
deviation.TT_mean = round(mean(deviation.TT_vect));
deviation.TT_std  = round(std(deviation.TT_vect));


%% Print

fprintf('\n')
fprintf('Direct : \n')
disp(direct)

fprintf('\n')
fprintf('Deviation : \n')
disp(deviation)


end % function
