function StartTime = StartTimeEvent
global S

switch S.OperationMode
    case 'Acquisition'
        HideCursor(S.ScreenID)
    case 'FastDebug'
    case 'RealisticDebug'
        HideCursor(S.ScreenID)
    otherwise
end

% Synchronization
StartTime = WaitForTTL;

end % function
