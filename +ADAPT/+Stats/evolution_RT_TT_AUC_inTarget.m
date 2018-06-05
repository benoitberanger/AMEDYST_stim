function [ output ] = evolution_RT_TT_AUC_inTarget
global S


%% Shortcut

gloAU = S.Stats.global_AUC_inBlock;


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
    
    targets_in_block = floor([gloAU.(name).Trials.target]);
    [Targets,~,trial2target] = unique(targets_in_block);
    Targets = floor(Targets);
    
    s = struct;
    for target_idx = 1 : length(Targets)
        s.Targets(target_idx).target   = Targets(target_idx);
        s.Targets(target_idx).idx     = find(trial2target==target_idx);
        s.Targets(target_idx).RT      = [gloAU.(name).Trials(s.Targets(target_idx).idx).RT ];
        s.Targets(target_idx).RTmean  = nanmean(s.Targets(target_idx).RT);
        s.Targets(target_idx).RTstd   = nanstd (s.Targets(target_idx).RT);
        s.Targets(target_idx).TT      = [gloAU.(name).Trials(s.Targets(target_idx).idx).TT ];
        s.Targets(target_idx).TTmean  = nanmean(s.Targets(target_idx).TT);
        s.Targets(target_idx).TTstd   = nanstd (s.Targets(target_idx).TT);
        s.Targets(target_idx).AUC     = [gloAU.(name).Trials(s.Targets(target_idx).idx).auc];
        s.Targets(target_idx).AUCmean = nanmean(s.Targets(target_idx).AUC);
        s.Targets(target_idx).AUCstd  = nanstd (s.Targets(target_idx).AUC);
    end
    output.(name) = s;
    
end % block

output.content = mfilename;


end % function
