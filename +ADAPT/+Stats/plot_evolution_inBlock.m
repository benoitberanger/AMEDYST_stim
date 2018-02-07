function plot_evolution_inBlock
global S

input = S.Stats.evolution_RT_TT_inBlock;

N1 = length(input.Direct_Pre.RTmean);
N2 = length(input.Deviaton.RTmean);
N3 = length(input.Direct_Post.RTmean);

N = N1 + N2 + N3;

figure('Name','Evolution of RT TT in blocks','NumberTitle','off')
ax(1) = subplot(2,1,1); hold(ax(1),'on');
ax(2) = subplot(2,1,2); hold(ax(2),'on');


for block = 1 : 3
    
    switch block
        case 1
            idx_b1 = 1:N1;
            if ~isempty(idx_b1)
                plot(ax(1), idx_b1,input.Direct_Pre.RTmean, 'DisplayName','Direct-Pre'  )
                plot(ax(2), idx_b1,input.Direct_Pre.TTmean, 'DisplayName','Direct-Pre'  )
            end
        case 2
            if ~isempty(idx_b1)
                idx_b2 = idx_b1(end)+1:idx_b1(end)+N2;
                plot(ax(1), idx_b2,input.Deviaton.RTmean   ,'DisplayName','Deviaton'   )
                plot(ax(2), idx_b2,input.Deviaton.TTmean   ,'DisplayName','Deviaton'   )
            end
        case 3
            if ~isempty(idx_b2)
                idx_b3 = idx_b2(end)+1:idx_b2(end)+N3;
                plot(ax(1), idx_b3,input.Direct_Post.RTmean,'DisplayName','Direct-Post')
                plot(ax(2), idx_b3,input.Direct_Post.TTmean,'DisplayName','Direct-Post')
            end
        otherwise
            error('block ?')
    end
    
end % block

legend(ax(1),'show')
xlabel(ax(1),'each point is the mean of 4 trials')
ylabel(ax(1),'RT in milliseconds')
set   (ax(1),'XTick',1:N)
legend(ax(2),'show')
xlabel(ax(2),'each point is the mean of 4 trials')
ylabel(ax(2),'TT in milliseconds')
set   (ax(2),'XTick',1:N)

linkaxes(ax,'xy')

end % function
