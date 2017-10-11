function ParPortMessages = PrepareParPort
global S

%% On ? Off ?

switch S.ParPort
    
    case 'On'
        
        % Open parallel port
        OpenParPort;
        
        % Set pp to 0
        WriteParPort(0)
        
    case 'Off'
        
end

%% Prepare messages

% % Finger tap
msg.finger_1 = 1;
msg.finger_2 = 2;
msg.finger_3 = 3;
msg.finger_4 = 4;
msg.finger_5 = 5;

% Audio instructions
msg.Rest        = 10;
msg.Instruction = 20;
msg.Simple      = 30;
msg.Complex     = 40;


%% Finalize

% Pulse duration
msg.duration    = 0.003; % seconds

ParPortMessages = msg; % shortcut

end % function
