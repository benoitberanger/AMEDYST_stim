function plot_evolution_inBlock
global S

%% Shortcut

evoRT = S.Stats.evolution_RT_TT_inBlock;
gloRT = S.Stats.global_RT_TT_inBlock;

data  = S.TaskData.OutRecorder.Data;
NrAngles = length(S.TaskData.Parameters.TargetAngles);

colors = lines(3);


%% Plot

figure('Name','Evolution of RT TT in blocks','NumberTitle','off')

nAxes = 3;
ax = zeros(nAxes,1);

for a = 1:nAxes
    ax(a) = subplot(nAxes,1,a); hold(ax(a),'all');
end

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
    
    plot(ax(1) ,block_idx, data(block_idx,9 ), '-s', 'Color',colors(block,:), 'LineWidth',2, 'DisplayName',name)
    plot(ax(2), block_idx, data(block_idx,10), '-s', 'Color',colors(block,:), 'LineWidth',2, 'DisplayName',name)
    % boxplot(ax(1),data(blk_idx,9),'Position',mean(blk_idx),'Notch','off','Whisker',1)
    % boxplot(ax(2),data(blk_idx,10),'Position',mean(blk_idx),'Notch','off','Whisker',1)
    block_X_pos = mean(block_idx);
    bar     (ax(1), block_X_pos, gloRT.(name).RTmean, length(block_idx), 'FaceColor','none', 'EdgeColor',colors(block,:)*0.5, 'LineStyle','--')
    bar     (ax(2), block_X_pos, gloRT.(name).TTmean, length(block_idx), 'FaceColor','none', 'EdgeColor',colors(block,:)*0.5, 'LineStyle','--')
    errorbar(ax(1), block_X_pos, gloRT.(name).RTstd, std(data(block_idx,9 )), 'Color',colors(block,:)*0.5, 'LineStyle','--')
    errorbar(ax(2), block_X_pos, gloRT.(name).RTstd, std(data(block_idx,10)), 'Color',colors(block,:)*0.5, 'LineStyle','--')
    
    % --- bar + error (chunck@block) ---
    
    % Adjust number of chunks if necessary, be thow a warning
    NrChunks = length(evoRT.(name).chunk_idx);
    
    for chunk = 1 : NrChunks
        chunk_idx = evoRT.(name).chunk_idx{chunk};
        chunk_X_pos = mean(chunk_idx)+(block-1)*NrChunks*NrAngles;
        % boxplot(ax(1),data_in_block(chk_idx,9),'Position',mean(chk_idx)+(block-1)*NrChunks*NrAngles,'Color',colors(block,:),'Notch','off','Whisker',1)
        % boxplot(ax(2),data_in_block(chk_idx,10),'Position',mean(chk_idx)+(block-1)*NrChunks*NrAngles,'Color',colors(block,:),'Notch','off','Whisker',1)
        bar     (ax(1), chunk_X_pos, evoRT.(name).RTmean(chunk), NrAngles, 'FaceColor','none', 'EdgeColor',colors(block,:))
        bar     (ax(2), chunk_X_pos, evoRT.(name).TTmean(chunk), NrAngles, 'FaceColor','none', 'EdgeColor',colors(block,:))
        errorbar(ax(1), chunk_X_pos, evoRT.(name).RTmean(chunk), evoRT.(name).RTstd(chunk), 'Color',colors(block,:))
        errorbar(ax(2), chunk_X_pos, evoRT.(name).TTmean(chunk), evoRT.(name).TTstd(chunk), 'Color',colors(block,:))
    end
    
end % block


for a = 1:nAxes
    
    axis(ax(a),'tight')
    % legend(ax(a),'show')
    xlabel(ax(a),'each point is the mean of 4 trials')
    set   (ax(a),'XTick',1:size(data,1))
    set   (ax(a),'XTickLabel',num2cell(1:size(data,1)))
    
end

ylabel(ax(1),'RT in milliseconds')
ylabel(ax(2),'TT in milliseconds')

linkaxes(ax,'xy')
% ScaleAxisLimits(ax(1))


end % function
