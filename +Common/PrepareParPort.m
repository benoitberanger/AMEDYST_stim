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


%% SEQ

% Finger tap
msg.finger_1 = 1;
msg.finger_2 = 2;
msg.finger_3 = 3;
msg.finger_4 = 4;
msg.finger_5 = 5;

% Audio instructions
msg.Repos       = 10;
msg.Instruction = 20;
msg.Simple      = 30;
msg.Complexe    = 40;


%% ADAPT

msg.Jitter          = 1;
msg.ShowProbability = 2;
msg.PausePreMotor   = 3;

msg.Motor__Start    = 4;
msg.Motor__RT       = 5;
msg.Motor__TT       = 6;

msg.GoBack__Start   = 7;
msg.GoBack__RT      = 8;
msg.GoBack__TT      = 9;

msg.PausePreReward  = 10;
msg.ShowReward      = 11;


%% Finalize

% Pulse duration
msg.duration    = 0.003; % seconds

ParPortMessages = msg; % shortcut

end % function
