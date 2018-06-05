function [ output ] = global_AUC_inBlock
global S

output = struct;


%% Shortcut

data     = S.TaskData.OutRecorder.Data;
samples  = S.TaskData.SR         .Data;
targetPx = S.TaskData.TargetBigCirclePosition;


%% Make stats for each block

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
    
    % Fetch data in the current block
    block_idx     = find(data(:,1)==block);
    
    if isempty( block_idx ) % no data for this block : ESCAPE key pressed ?
        continue
    end
    
    data_in_block = data( block_idx , : );
    NrTrials      = size(data_in_block,1);
    
    s = struct;
    
    for  trial = 1 : NrTrials
        
        frame_start = data_in_block(trial,7);
        frame_stop  = data_in_block(trial,8);
        
        xy = samples(frame_start:frame_stop,2:3);
        angle = data_in_block(trial,6)*pi/180; % degree to rad
        rotation_matrix = [cos(angle) -sin(angle); sin(angle) cos(angle)];
        xy = xy*rotation_matrix; % change referencial
        % xy = xy/targetY; % normalize
        
        auc = abs(trapz(xy(:,1),xy(:,2)));
        
        s.Trials(trial).idx         = data_in_block(trial,2);
        s.Trials(trial).frame_start = frame_start;
        s.Trials(trial).frame_stop  = frame_stop;
        s.Trials(trial).xy          = xy;
        s.Trials(trial).deviation   = data_in_block(trial,4);
        s.Trials(trial).value       = data_in_block(trial,5);
        s.Trials(trial).target      = data_in_block(trial,6);
        s.Trials(trial).targetPx    = targetPx;
        s.Trials(trial).auc         = auc;
        
        s.auc(trial) = auc;
        
        s.Trials(trial).RT          = data_in_block(trial,9 );
        s.Trials(trial).TT          = data_in_block(trial,10);
        
    end % trial
    
    s.block_idx = block_idx;
    s.AUCmean   = nanmean(s.auc);
    s.AUCstd    = nanstd (s.auc);
    
    output.(name) = s;
    
    fprintf('mean AUC in block ''%s'' = %g pixels² \n', name, round(s.AUCmean))
    fprintf('std  AUC in block ''%s'' = %g pixels² \n', name, round(s.AUCstd ))
    
end % block

output.content = mfilename;


end % function
