function plot_evolution_inBlock
global S

%% Shortcut

input = S.Stats.evolution_RT_TT_inBlock;
data  = S.TaskData.OutRecorder.Data;
NrAngles = length(S.TaskData.Parameters.TargetAngles);

colors = lines(3);


%% Plot

figure('Name','Evolution of RT TT in blocks','NumberTitle','off')

nAxes = 2;
ax = zeros(nAxes,1);

for a = 1:nAxes
    ax(a) = subplot(nAxes,1,a); hold(ax(a),'all');
end

for block = 1 : 3
    
    % Block name
    switch block
        case 1
            name = 'Direct-Pre';
        case 2
            name = 'Deviaton';
        case 3
            name = 'Direct-Post';
        otherwise
            error('block ?')
    end % switch
    
    % --- plot(block) + boxplot(plot) ---
    
    blk_idx = find(data(:,1) == block);
    
    plot(ax(1),blk_idx,data(blk_idx,9) ,'-s','Color',colors(block,:),'LineWidth',2,'DisplayName',name)
    plot(ax(2),blk_idx,data(blk_idx,10),'-s','Color',colors(block,:),'LineWidth',2,'DisplayName',name)
    % boxplot(ax(1),data(blk_idx,9),'Position',mean(blk_idx),'Notch','off','Whisker',1)
    % boxplot(ax(2),data(blk_idx,10),'Position',mean(blk_idx),'Notch','off','Whisker',1)
    bar     (ax(1),mean(blk_idx),mean(data(blk_idx,9 )),length(blk_idx),'FaceColor','none','EdgeColor',colors(block,:)*0.5,'LineStyle','--')
    bar     (ax(2),mean(blk_idx),mean(data(blk_idx,10)),length(blk_idx),'FaceColor','none','EdgeColor',colors(block,:)*0.5,'LineStyle','--')
    errorbar(ax(1),mean(blk_idx),mean(data(blk_idx,9 )),std(data(blk_idx,9 )),'Color',colors(block,:)*0.5,'LineStyle','--')
    errorbar(ax(2),mean(blk_idx),mean(data(blk_idx,10)),std(data(blk_idx,10)),'Color',colors(block,:)*0.5,'LineStyle','--')
    
    % --- boxplot(chunck@block) ---
    
    % Fetch data in the current block
    data_in_block = data( data(:,1)==block , : );
    
    % Adjust number of chunks if necessary, be thow a warning
    NrChunks = size(data_in_block,1)/NrAngles;
    if NrChunks ~= round(NrChunks)
        warning('chunk error : not an integer, in block #%d', block)
    end
    NrChunks = floor(NrChunks);
    
    for chunk = 1 : NrChunks
        chk_idx = NrAngles * (chunk-1) + 1   :   NrAngles * chunk;
        % boxplot(ax(1),data_in_block(chk_idx,9),'Position',mean(chk_idx)+(block-1)*NrChunks*NrAngles,'Color',colors(block,:),'Notch','off','Whisker',1)
        % boxplot(ax(2),data_in_block(chk_idx,10),'Position',mean(chk_idx)+(block-1)*NrChunks*NrAngles,'Color',colors(block,:),'Notch','off','Whisker',1)
        bar(ax(1),mean(chk_idx)+(block-1)*NrChunks*NrAngles,mean(data_in_block(chk_idx,9 )),NrAngles,'FaceColor','none','EdgeColor',colors(block,:))
        bar(ax(2),mean(chk_idx)+(block-1)*NrChunks*NrAngles,mean(data_in_block(chk_idx,10)),NrAngles,'FaceColor','none','EdgeColor',colors(block,:))
        errorbar(ax(1),mean(chk_idx)+(block-1)*NrChunks*NrAngles,mean(data_in_block(chk_idx,9 )),std(data_in_block(chk_idx,9 )),'Color',colors(block,:))
        errorbar(ax(2),mean(chk_idx)+(block-1)*NrChunks*NrAngles,mean(data_in_block(chk_idx,10)),std(data_in_block(chk_idx,10)),'Color',colors(block,:))
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
