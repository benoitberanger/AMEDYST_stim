function [ Parameters ] = GetParameters
% GETPARAMETERS Prepare common parameters
global S


%% Echo in command window

EchoStart(mfilename)


%% Paths

% Parameters.Path.wav = ['wav' filesep];


%% Set parameters

%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

% Parameters.Audio.SamplingRate            = 44100; % Hz
%
% Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
% Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
% Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate ;
% Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo
%
% Parameters.Audio.Record_Mode             = 2; % 1 = playback, 2 = record
% Parameters.Audio.Record_LowLatencyMode   = 0; % {0,1,2,3,4}
% Parameters.Audio.Record_freq             = Parameters.Audio.SamplingRate;
% Parameters.Audio.Record_Channels         = 1; % 1 = mono, 2 = stereo


%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
Parameters.Video.ScreenWidthPx   = 1024;  % Number of horizontal pixel in MRI video system @ CENIR
Parameters.Video.ScreenHeightPx  = 768;   % Number of vertical pixel in MRI video system @ CENIR
Parameters.Video.ScreenFrequency = 60;    % Refresh rate (in Hertz)
Parameters.Video.SubjectDistance = 0.120; % m
Parameters.Video.ScreenWidthM    = 0.040; % m
Parameters.Video.ScreenHeightM   = 0.030; % m

Parameters.Video.ScreenBackgroundColor = [50 50 50]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%
%   Text   %
%%%%%%%%%%%%
Parameters.Text.SizeRatio   = 0.10; % Size = ScreenWide *ratio
Parameters.Text.Font        = 'Arial';
Parameters.Text.Color       = [128 128 128]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%
%   SEQ    %
%%%%%%%%%%%%

% Fixation cross
Parameters.SEQ.FixationCross.ScreenRatio    = 0.10;          % ratio : dim   = ScreenWide *ratio_screen
Parameters.SEQ.FixationCross.lineWidthRatio = 0.05;          % ratio : width = dim        *ratio_width
Parameters.SEQ.FixationCross.Color          = [128 128 128]; % [R G B] ( from 0 to 255 )

% ResponseButtons
Parameters.SEQ.ResponseButtons.ScreenRatio  = 0.60;           % height = ScreenHeight * ratio
Parameters.SEQ.ResponseButtons.Side         = S.Side;        % 'Left' or 'Right'
Parameters.SEQ.ResponseButtons.frameColor   = [128 128 128]; % [R G B] ( from 0 to 255 )
Parameters.SEQ.ResponseButtons.buttonsColor = ...
    [255 80 60    % 5 == red
    30 190 70     % 4 == green
    255 224 54    % 3 == yellow
    40 100 210]'; % 2 == blue
% [R G B] ( from 0 to 255 )
% colors here are both left and right buttons


%%%%%%%%%%%%%%
%   ADAPT    %
%%%%%%%%%%%%%%

% Big circle => @Circle
Parameters.ADAPT.Circle.DimensionRatio = 0.90;                                   % diameter  = DimensionRatio*ScreenHeight
Parameters.ADAPT.Circle.WidthRatio     = 0.01;                                   % thickness = WidthRatio    *diameter
Parameters.ADAPT.Circle.FrameColor     = [128 128 128];                          % [R G B] ( from 0 to 255 )
Parameters.ADAPT.Circle.DiskColor      = Parameters.Video.ScreenBackgroundColor; % [R G B] ( from 0 to 255 )
Parameters.ADAPT.Circle.ValueColor     = [0 0 0]; % [R G B] ( from 0 to 255 )

% Target => @Circle
Parameters.ADAPT.Target.DimensionRatio = 0.10;                                   % diameter  = DimensionRatio*ScreenHeight
Parameters.ADAPT.Target.WidthRatio     = 0.10;                                   % thickness = WidthRatio    *diameter
Parameters.ADAPT.Target.FrameColor     = [255 255 255];                          % [R G B] ( from 0 to 255 )
Parameters.ADAPT.Target.DiskColor      = Parameters.Video.ScreenBackgroundColor; % [R G B] ( from 0 to 255 )
Parameters.ADAPT.Target.ValueColor     = [0 0 0];                                % [R G B] ( from 0 to 255 )

% Cursor => @Dot
Parameters.ADAPT.Cursor.DimensionRatio = 0.04;        % diameter = DimensionRatio*ScreenHeight
Parameters.ADAPT.Cursor.DiskColor      = [255 255 0]; % [R G B] ( from 0 to 255 )

% Small cross at the center => @FixationCross
Parameters.ADAPT.Cross.ScreenRatio    = 0.05;          % ratio : dim   = ScreenHeight*ratio_screen
Parameters.ADAPT.Cross.lineWidthRatio = 0.05;          % ratio : width = dim         *ratio_width
Parameters.ADAPT.Cross.Color          = [128 128 128]; % [R G B] ( from 0 to 255 )


%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');


Parameters.Keybinds.TTL_t_ASCII          = KbName('t'); % MRI trigger has to be the first defined key
% Parameters.Keybinds.emulTTL_s_ASCII      = KbName('s');
Parameters.Keybinds.Stop_Escape_ASCII    = KbName('ESCAPE');

switch S.Environement
    
    case 'MRI'
        
        Parameters.Fingers.Right(1) = 1;           % Thumb, not on the response buttons, arbitrary number
        Parameters.Fingers.Right(2) = KbName('b'); % Index finger
        Parameters.Fingers.Right(3) = KbName('y'); % Middle finger
        Parameters.Fingers.Right(4) = KbName('g'); % Ring finger
        Parameters.Fingers.Right(5) = KbName('r'); % Little finger
        
        Parameters.Fingers.Left (1) = 2;           % Thumb, not on the response buttons, arbitrary number
        Parameters.Fingers.Left (2) = KbName('e'); % Index finger
        Parameters.Fingers.Left (3) = KbName('z'); % Middle finger
        Parameters.Fingers.Left (4) = KbName('n'); % Ring finger
        Parameters.Fingers.Left (5) = KbName('d'); % Little finger
        
    case 'Practice'
        
        Parameters.Fingers.Left (1) = KbName('v'); % Thumb, not on the response buttons, arbitrary number
        Parameters.Fingers.Left (2) = KbName('f'); % Index finger
        Parameters.Fingers.Left (3) = KbName('d'); % Middle finger
        Parameters.Fingers.Left (4) = KbName('s'); % Ring finger
        Parameters.Fingers.Left (5) = KbName('q'); % Little finger
        
        Parameters.Fingers.Right(1) = KbName('b'); % Thumb, not on the response buttons, arbitrary number
        Parameters.Fingers.Right(2) = KbName('h'); % Index finger
        Parameters.Fingers.Right(3) = KbName('j'); % Middle finger
        Parameters.Fingers.Right(4) = KbName('k'); % Ring finger
        Parameters.Fingers.Right(5) = KbName('l'); % Little finger
        
end

Parameters.Fingers.All      = [fliplr(Parameters.Fingers.Left) Parameters.Fingers.Right];
Parameters.Fingers.Names    = {'L5' 'L4' 'L3' 'L2' 'L1' 'R1' 'R2' 'R3' 'R4' 'R5'};


%% Echo in command window

EchoStop(mfilename)


end