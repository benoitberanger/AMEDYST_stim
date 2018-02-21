function plot_stat_by_target( S )


%% Shortcut

evoTG = S.Stats.evolution_RT_TT_AUC_inTarget;

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
    
    for target_idx =  1 : length(evoTG.Deviaton.Targets)
        counter_X_pos = counter_X_pos + 1;
        bar     (ax(1), counter_X_pos, evoTG.(name).Targets(target_idx).RTmean,  1, 'FaceColor','none', 'EdgeColor',colors(block,:), 'LineStyle','-', 'DisplayName',['mean ' name])
        bar     (ax(2), counter_X_pos, evoTG.(name).Targets(target_idx).TTmean,  1, 'FaceColor','none', 'EdgeColor',colors(block,:), 'LineStyle','-', 'DisplayName',['mean ' name])
        bar     (ax(3), counter_X_pos, evoTG.(name).Targets(target_idx).AUCmean, 1, 'FaceColor','none', 'EdgeColor',colors(block,:), 'LineStyle','-', 'DisplayName',['mean ' name])
        errorbar(ax(1), counter_X_pos, evoTG.(name).Targets(target_idx).RTmean,  evoTG.(name).Targets(target_idx).RTstd,  'Color',colors(block,:), 'LineStyle','--', 'DisplayName',['std ' name])
        errorbar(ax(2), counter_X_pos, evoTG.(name).Targets(target_idx).TTmean,  evoTG.(name).Targets(target_idx).TTstd,  'Color',colors(block,:), 'LineStyle','--', 'DisplayName',['std ' name])
        errorbar(ax(3), counter_X_pos, evoTG.(name).Targets(target_idx).AUCmean, evoTG.(name).Targets(target_idx).AUCstd, 'Color',colors(block,:), 'LineStyle','--', 'DisplayName',['std ' name])
    end
    
end % block


%% Adjustments

allTargets = [evoTG.Deviaton.Targets.target];

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
