function [ output ] = evolution_RT_TT_AUC_inRewardChance
global S


%% Shortcut

gloAU = S.Stats.global_AUC_inBlock;
% Values = floor(sort(S.TaskData.Parameters.Values));


%% Extract data

for block = 1 : 3
    
   % Block name
    switch block
        case 1
            name = 'Direct__Pre';
        case 2
            name = 'Deviation';
        case 3
            name = 'Direct__Post';
        otherwise
            error('block ?')
    end % switch
    
    if ~isfield(gloAU,name)
        continue
    end
    
    values_in_block = floor([gloAU.(name).Trials.value]);
    [Values,~,trial2value] = unique(values_in_block);
    Values = floor(Values);
    
    s = struct;
    for value_idx = 1 : length(Values)
        s.Values(value_idx).value   = Values(value_idx);
        s.Values(value_idx).idx     = find(trial2value==value_idx);
        s.Values(value_idx).RT      = [gloAU.(name).Trials(s.Values(value_idx).idx).RT ];
        s.Values(value_idx).RTmean  = mean(s.Values(value_idx).RT);
        s.Values(value_idx).RTstd   = std (s.Values(value_idx).RT);
        s.Values(value_idx).TT      = [gloAU.(name).Trials(s.Values(value_idx).idx).TT ];
        s.Values(value_idx).TTmean  = mean(s.Values(value_idx).TT);
        s.Values(value_idx).TTstd   = std (s.Values(value_idx).TT);
        s.Values(value_idx).AUC     = [gloAU.(name).Trials(s.Values(value_idx).idx).auc];
        s.Values(value_idx).AUCmean = mean(s.Values(value_idx).AUC);
        s.Values(value_idx).AUCstd  = std (s.Values(value_idx).AUC);
    end
    output.(name) = s;
    
end % block

output.content = mfilename;


end % function
