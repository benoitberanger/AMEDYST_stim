function plot_evolution_inBlock
global S


%% Shortcut

evoRT = S.Stats.evolution_RT_TT_inBlock;
gloRT = S.Stats.global_RT_TT_inBlock;
evoAU = S.Stats.evolution_AUC_inBlock;
gloAU = S.Stats.global_AUC_inBlock;

data  = S.TaskData.OutRecorder.Data;
NrAngles = length(S.TaskData.Parameters.TargetAngles);

colors = lines(3);


%% Plot

figure('Name','Evolution of RT TT AUC in blocks, chunk by chunk','NumberTitle','off')

nAxes = 3;
ax = zeros(nAxes,1);

for a = 1:nAxes
    ax(a) = subplot(nAxes,1,a);
    hold(ax(a),'all');
end

chunk_offcet = 0;
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
    
    % --- plot(block) // bar + error(plot) ---
    
    block_idx = gloRT.(name).block_index;
    
    plot(ax(1) ,block_idx, data(block_idx,9 ), ':', 'Color',colors(block,:), 'LineWidth',1, 'DisplayName',name)
    plot(ax(2), block_idx, data(block_idx,10), ':', 'Color',colors(block,:), 'LineWidth',1, 'DisplayName',name)
    plot(ax(3), block_idx, gloAU.(name).auc,   ':', 'Color',colors(block,:), 'LineWidth',1, 'DisplayName',name)
    
    block_X_pos = mean(block_idx);
    bar     (ax(1), block_X_pos, gloRT.(name).RTmean,  length(block_idx), 'FaceColor','none', 'EdgeColor',colors(block,:)*0.5, 'LineStyle','-', 'DisplayName',['mean ' name])
    bar     (ax(2), block_X_pos, gloRT.(name).TTmean,  length(block_idx), 'FaceColor','none', 'EdgeColor',colors(block,:)*0.5, 'LineStyle','-', 'DisplayName',['mean ' name])
    bar     (ax(3), block_X_pos, gloAU.(name).AUCmean, length(block_idx), 'FaceColor','none', 'EdgeColor',colors(block,:)*0.5, 'LineStyle','-', 'DisplayName',['mean ' name])
    errorbar(ax(1), block_X_pos, gloRT.(name).RTmean,  gloRT.(name).RTstd,  'Color',colors(block,:)*0.5, 'LineStyle','--', 'DisplayName',['std ' name])
    errorbar(ax(2), block_X_pos, gloRT.(name).TTmean,  gloRT.(name).TTstd,  'Color',colors(block,:)*0.5, 'LineStyle','--', 'DisplayName',['std ' name])
    errorbar(ax(3), block_X_pos, gloAU.(name).AUCmean, gloAU.(name).AUCstd, 'Color',colors(block,:)*0.5, 'LineStyle','--', 'DisplayName',['std ' name])
    
    % --- bar + error (chunck@block) ---
    
    % Adjust number of chunks if necessary, be thow a warning
    NrChunks = length(evoRT.(name).chunk_idx);
    
    for chunk = 1 : NrChunks(end)
        chunk_idx = evoRT.(name).chunk_idx{chunk};
        chunk_X_pos = mean(chunk_idx)+chunk_offcet;
        bar     (ax(1), chunk_X_pos, evoRT.(name).RTmean(chunk),        NrAngles, 'FaceColor','none', 'EdgeColor',colors(block,:) ,'LineWidth',1.5, 'DisplayName',['mean ' name])
        bar     (ax(2), chunk_X_pos, evoRT.(name).TTmean(chunk),        NrAngles, 'FaceColor','none', 'EdgeColor',colors(block,:) ,'LineWidth',1.5, 'DisplayName',['mean ' name])
        bar     (ax(3), chunk_X_pos, evoAU.(name).Chunk(chunk).AUCmean, NrAngles, 'FaceColor','none', 'EdgeColor',colors(block,:) ,'LineWidth',1.5, 'DisplayName',['mean ' name])
        errorbar(ax(1), chunk_X_pos, evoRT.(name).RTmean(chunk),        evoRT.(name).RTstd(chunk),        'Color',colors(block,:) ,'LineWidth',1.5, 'DisplayName',['std ' name])
        errorbar(ax(2), chunk_X_pos, evoRT.(name).TTmean(chunk),        evoRT.(name).TTstd(chunk),        'Color',colors(block,:) ,'LineWidth',1.5, 'DisplayName',['std ' name])
        errorbar(ax(3), chunk_X_pos, evoAU.(name).Chunk(chunk).AUCmean, evoAU.(name).Chunk(chunk).AUCstd, 'Color',colors(block,:) ,'LineWidth',1.5, 'DisplayName',['std ' name])
    end
    chunk_offcet = chunk_offcet + NrChunks*NrAngles;
    
end % block


%% Adjustments

for a = 1:nAxes
    axis(ax(a),'tight')
    % legend(ax(a),'show')
    xlabel(ax(a),'each point is the mean of 4 trials')
    set   (ax(a),'XTick',1:size(data,1))
    set   (ax(a),'XTickLabel',num2cell(1:size(data,1)))
end

ylabel(ax(1),'RT in milliseconds')
ylabel(ax(2),'TT in milliseconds')
ylabel(ax(3),'AUC in pixel²')

linkaxes(ax(1:2),'xy')
linkaxes(ax,'x')
% ScaleAxisLimits(ax(1))


end % function
