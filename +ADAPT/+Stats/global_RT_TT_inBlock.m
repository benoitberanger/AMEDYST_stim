function [ output ] = global_RT_TT_inBlock
global S

output = struct;


%% Shortcut

data = S.TaskData.OutRecorder.Data;


%% Make stats for each NrAngles

for block = 1 : 3
    
    % Fetch data in the current block
    data_in_block = data( data(:,1)==block , : );
    
    RTmean = mean(data_in_block(:,9));
    RTstd  =  std(data_in_block(:,9));
    
    TTmean = mean(data_in_block(:,10));
    TTstd  =  std(data_in_block(:,10));
    
    s = struct;
    s.RTmean = RTmean;
    s.RTstd  = RTstd ;
    s.TTmean = TTmean;
    s.TTstd  = TTstd ;
    
    % Block name
    switch block
        case 1
            name = 'Direct_Pre';
        case 2
            name = 'Deviaton';
        case 3
            name = 'Direct_Post';
        otherwise
            error('block ?')
    end % switch
    
    output.(name)  = s;
    output.content = mfilename;
    
    fprintf('mean RT in block ''%s'' = %g ms \n', name, round(RTmean))
    fprintf('std  RT in block ''%s'' = %g ms \n', name, round(RTstd ))
    fprintf('mean TT in block ''%s'' = %g ms \n', name, round(TTmean))
    fprintf('std  TT in block ''%s'' = %g ms \n', name, round(TTstd ))
    
end % block


end % function
