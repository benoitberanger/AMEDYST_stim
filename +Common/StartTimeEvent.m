function StartTime = StartTimeEvent

global S  reverseStr
reverseStr = '';

switch S.OperationMode
    case 'Acquisition'
        HideCursor;
    case 'FastDebug'
    case 'RealisticDebug'
    otherwise
end

% Synchronization
StartTime = WaitForTTL;

end % function
