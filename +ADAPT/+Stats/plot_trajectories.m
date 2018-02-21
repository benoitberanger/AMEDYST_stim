function plot_trajectories( S )


%% Shortcut

data = S.Stats.global_AUC_inBlock;


%% Plot

figure('Name','Plot Y(X) in untilted referiential (like target=0°)', 'NumberTitle','off');
nAxes = 3;
ax = zeros(nAxes,1);

for a = 1:nAxes
    ax(a) = subplot(nAxes,1,a);
    hold(ax(a),'all');
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
    
    if ~isfield(data,name)
        continue
    end
    
    NrTrials = length(data.(name).Trials);
    
    for trial = 1 : NrTrials
        plot( ax(block), data.(name).Trials(trial).xy(:,1), data.(name).Trials(trial).xy(:,2) )
    end % trial
    
    % ideal trajectorty
    plot( ax(block), [0 data.(name).Trials(trial).targetPx], [0 0], 'k', 'LineWidth', 2, 'DisplayName', 'optimal');
    
    axis  (ax(block),'tight')
    % legend(ax(a),'show')
    xlabel(ax(block),'X (pixels)')
    ylabel(ax(block),'Y (pixels)')
    title (ax(block),name,'Interpreter','none')
    
end % block

linkaxes(ax,'xy')
% ScaleAxisLimits(ax(1))


end % function
