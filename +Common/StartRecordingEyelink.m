function StartRecordingEyelink
global S

% Eyelink mode 'On' ?
switch S.EyelinkMode
    case 'On'
        
        % Acquisition ?
        switch S.OperationMode
            
            case 'Acquisition'
                
                Eyelink.storeELfilename( S.DataPath, S.EyelinkFile, S.DataFileName ) % security
                
                Eyelink.StartRecording( S.EyelinkFile );
                
            otherwise
                error('Task:EyelinkWithourAcquisition','\n Eyelink mode should be ''Off'' if not in Acquisition mode \n')
                
        end
        
    case 'Off'
        
    otherwise
        
end

end % function
