function printResults( ER )

for evt = 1 : ER.EventCount

    if ~isempty(ER.Data{evt,4})
        
        fprintf('\n')
        fprintf('Block : %s \n', ER.Data{evt,1})
        disp(ER.Data{evt,4})
        
    end
    
end

end % function
