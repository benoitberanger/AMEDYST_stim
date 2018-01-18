function [direct, deviation] = mean_std_RT_TT
global S

%% Shortcut

from = S.TaskData.OutRecorder.Data;


%% Fetch index

% direct   .idx  = find(from(:,4) == 0  ); direct   .ref = 1;
% deviation.idx  = find(from(:,4) ~= 0  ); deviation.ref = 2;

% % f*ck its not optimized, not modular, but...
% value000 .idx  = find(from(:,5) == 000); value000 .ref = 1;
% value025 .idx  = find(from(:,5) == 025); value025 .ref = 2;
% value050 .idx  = find(from(:,5) == 050); value050 .ref = 3;
% value075 .idx  = find(from(:,5) == 075); value075 .ref = 4;
% value100 .idx  = find(from(:,5) == 100); value100 .ref = 5;
%
% Table_idx{ direct   .ref, value000.ref } = intersect(direct   .idx,value000.idx);
% Table_idx{ direct   .ref, value025.ref } = intersect(direct   .idx,value025.idx);
% Table_idx{ direct   .ref, value050.ref } = intersect(direct   .idx,value050.idx);
% Table_idx{ direct   .ref, value075.ref } = intersect(direct   .idx,value075.idx);
% Table_idx{ direct   .ref, value100.ref } = intersect(direct   .idx,value100.idx);
% Table_idx{ deviation.ref, value000.ref } = intersect(deviation.idx,value000.idx);
% Table_idx{ deviation.ref, value025.ref } = intersect(deviation.idx,value025.idx);
% Table_idx{ deviation.ref, value050.ref } = intersect(deviation.idx,value050.idx);
% Table_idx{ deviation.ref, value075.ref } = intersect(deviation.idx,value075.idx);
% Table_idx{ deviation.ref, value100.ref } = intersect(deviation.idx,value100.idx);


%% Compute mean & std for ReactionTime and TravelTime

% Direct

direct         = struct;
direct.idx     = find(from(:,4) == 0);

direct.RT_vect = from(direct.idx,9);
direct.RT_mean = round(mean(direct.RT_vect));
direct.RT_std  = round( std(direct.RT_vect));

direct.TT_vect = from(direct.idx,10);
direct.TT_mean = round(mean(direct.TT_vect));
direct.TT_std  = round( std(direct.TT_vect));


% Deviation

deviation         = struct;
deviation.idx     = find(from(:,4) ~= 0);

deviation.RT_vect = from(deviation.idx,9);
deviation.RT_mean = round(mean(deviation.RT_vect));
deviation.RT_std  = round( std(deviation.RT_vect));

deviation.TT_vect = from(deviation.idx,10);
deviation.TT_mean = round(mean(deviation.TT_vect));
deviation.TT_std  = round( std(deviation.TT_vect));


% Direct(value) & Deviation(value)
sortedValues = sort(S.TaskData.Parameters.Values);
for currentValue = sortedValues
    
    vect = intersect(direct.idx, find(from(:,5)==currentValue) );
    name = sprintf('value%.3d',currentValue);
    direct.(name).RT_vect = from(vect,9);
    direct.(name).RT_mean = round(mean(direct.(name).RT_vect));
    direct.(name).RT_std  = round( std(direct.(name).RT_vect));
    direct.(name).TT_vect = from(vect,10);
    direct.(name).TT_mean = round(mean(direct.(name).TT_vect));
    direct.(name).TT_std  = round( std(direct.(name).TT_vect));
    
    vect = intersect(deviation.idx, find(from(:,5)==currentValue) );
    name = sprintf('value%.3d',currentValue);
    deviation.(name).RT_vect = from(vect,9);
    deviation.(name).RT_mean = round(mean(deviation.(name).RT_vect));
    deviation.(name).RT_std  = round( std(deviation.(name).RT_vect));
    deviation.(name).TT_vect = from(vect,10);
    deviation.(name).TT_mean = round(mean(deviation.(name).TT_vect));
    deviation.(name).TT_std  = round( std(deviation.(name).TT_vect));
    
end

%% Print

fprintf('\n')
fprintf('Direct : \n')
disp(direct)

fprintf('\n')
fprintf('Deviation : \n')
disp(deviation)


end % function
