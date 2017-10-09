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
% msg.finger_1 = 1;
% msg.finger_2 = 2;
% msg.finger_3 = 3;
% msg.finger_4 = 4;
% msg.finger_5 = 5;

% Audio instructions
msg.ReposRepos     = 10;
msg.ComplexComplex = 20;
msg.SimpleSimple   = 30;

msg.WakeUp         = 40;

% High / Low sounds
msg.LowBip  = 100;
msg.HighBip = 110;


%% Finalize

% Pulse duration
msg.duration    = 0.001; % seconds

ParPortMessages = msg; % shortcut

end % function
