function plot_stat_by_target( S )


%% Shortcut

evoTG = S.Stats.evolution_RT_TT_AUC_inTarget;

gloRT = S.Stats.global_RT_TT_inBlock;
gloAU = S.Stats.global_AUC_inBlock;

colors = lines(3);


%% Plot

figure('Name','Evolution of RT TT AUC in blocks, sorted by target position','NumberTitle','off')

nAxes = 3;
ax = zeros(nAxes,1);

for a = 1:nAxes
    ax(a) = subplot(nAxes,1,a);
    hold(ax(a),'all');
end

counter_X_pos = 0;
for block = 1 : 3
    
    % Block name
    switch block
        case 1
            name = 'Direct__Pre';
        case 2
            name = 'Deviaton';
        case 3
            name = 'Direct__Post';
        otherwise
            error('block ?')
    end % switch
    
    if ~isfield(evoTG,name)
        continue
    end
    
    nrTargets = length(evoTG.(name).Targets);
    
    for target_idx =  1 : nrTargets
        counter_X_pos = counter_X_pos + 1;
        bar     (ax(1), counter_X_pos, evoTG.(name).Targets(target_idx).RTmean,  1, 'FaceColor','none',               'EdgeColor',colors(block,:), 'LineWidth',1.5, 'DisplayName',['mean ' name])
        bar     (ax(2), counter_X_pos, evoTG.(name).Targets(target_idx).TTmean,  1, 'FaceColor','none',               'EdgeColor',colors(block,:), 'LineWidth',1.5, 'DisplayName',['mean ' name])
        bar     (ax(3), counter_X_pos, evoTG.(name).Targets(target_idx).AUCmean, 1, 'FaceColor','none',               'EdgeColor',colors(block,:), 'LineWidth',1.5, 'DisplayName',['mean ' name])
        errorbar(ax(1), counter_X_pos, evoTG.(name).Targets(target_idx).RTmean,  evoTG.(name).Targets(target_idx).RTstd,  'Color',colors(block,:), 'LineWidth',1.5, 'DisplayName',['std '  name])
        errorbar(ax(2), counter_X_pos, evoTG.(name).Targets(target_idx).TTmean,  evoTG.(name).Targets(target_idx).TTstd,  'Color',colors(block,:), 'LineWidth',1.5, 'DisplayName',['std '  name])
        errorbar(ax(3), counter_X_pos, evoTG.(name).Targets(target_idx).AUCmean, evoTG.(name).Targets(target_idx).AUCstd, 'Color',colors(block,:), 'LineWidth',1.5, 'DisplayName',['std '  name])
    end
    
    block_X_pos = counter_X_pos - nrTargets/2 + 0.5;
    bar     (ax(1), block_X_pos, gloRT.(name).RTmean,  nrTargets, 'FaceColor','none', 'EdgeColor',colors(block,:)*0.5, 'DisplayName',['mean ' name])
    bar     (ax(2), block_X_pos, gloRT.(name).TTmean,  nrTargets, 'FaceColor','none', 'EdgeColor',colors(block,:)*0.5, 'DisplayName',['mean ' name])
    bar     (ax(3), block_X_pos, gloAU.(name).AUCmean, nrTargets, 'FaceColor','none', 'EdgeColor',colors(block,:)*0.5, 'DisplayName',['mean ' name])
    errorbar(ax(1), block_X_pos, gloRT.(name).RTmean,  gloRT.(name).RTstd,                'Color',colors(block,:)*0.5, 'DisplayName',['std '  name])
    errorbar(ax(2), block_X_pos, gloRT.(name).TTmean,  gloRT.(name).TTstd,                'Color',colors(block,:)*0.5, 'DisplayName',['std '  name])
    errorbar(ax(3), block_X_pos, gloAU.(name).AUCmean, gloAU.(name).AUCstd,               'Color',colors(block,:)*0.5, 'DisplayName',['std '  name])
    
end % block


%% Adjustments

allTargets = [evoTG.Direct__Pre.Targets.target];

for a = 1:nAxes
    axis(ax(a),'tight')
    % legend(ax(a),'show')
    xlabel(ax(a),'Target position in degrees (°)')
    set   (ax(a),'XTick'     , 1:counter_X_pos)
    set   (ax(a),'XTickLabel', num2cell(repmat(allTargets,[1 block])) )
end

ylabel(ax(1),'RT in milliseconds')
ylabel(ax(2),'TT in milliseconds')
ylabel(ax(3),'AUC in pixel²')

linkaxes(ax(1:2),'xy')
linkaxes(ax,'x')
% ScaleAxisLimits(ax(1))


end % function
