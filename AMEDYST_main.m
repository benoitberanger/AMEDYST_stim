function AMEDYST_main(hObject, ~)
% AMEDYST_main is the main program, calling the different tasks and
% routines, according to the paramterts defined in the GUI


%% GUI : open a new one or retrive data from the current one

if nargin == 0
    
    AMEDYST_GUI;
    
    return
    
end

handles = guidata(hObject); % retrieve GUI data


%% MAIN : Clean the environment

clc
sca
rng('default')
rng('shuffle')


%% MAIN : Initialize the main structure

global S
S               = struct; % S is the main structure, containing everything usefull, and used everywhere
S.TimeStamp     = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
S.TimeStampFile = datestr(now, 30                ); % to sort automatically by time of creation


%% GUI : Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_SEQ'
        Task = 'SEQ';
        
    case 'pushbutton_ADAPT_HighReward'
        Task = 'ADAPT_HighReward';
        
    case 'pushbutton_ADAPT_LowReward'
        Task = 'ADAPT_LowReward';
        
    case 'pushbutton_EyelinkCalibration'
        Task = 'EyelinkCalibration';
        
    otherwise
        error('AMEDYST:TaskSelection','Error in Task selection')
end

S.Task = Task;


%% GUI : Environement selection

switch get(get(handles.uipanel_Environement,'SelectedObject'),'Tag')
    case 'radiobutton_MRI'
        Environement = 'MRI';
    case 'radiobutton_Practice'
        Environement = 'Practice';
    otherwise
        warning('AMEDYST:ModeSelection','Error in Environement selection')
end

S.Environement = Environement;


%% GUI : Save mode selection

switch get(get(handles.uipanel_SaveMode,'SelectedObject'),'Tag')
    case 'radiobutton_SaveData'
        SaveMode = 'SaveData';
    case 'radiobutton_NoSave'
        SaveMode = 'NoSave';
    otherwise
        warning('AMEDYST:SaveSelection','Error in SaveMode selection')
end

S.SaveMode = SaveMode;


%% GUI : Mode selection

switch get(get(handles.uipanel_OperationMode,'SelectedObject'),'Tag')
    case 'radiobutton_Acquisition'
        OperationMode = 'Acquisition';
    case 'radiobutton_FastDebug'
        OperationMode = 'FastDebug';
    case 'radiobutton_RealisticDebug'
        OperationMode = 'RealisticDebug';
    otherwise
        warning('AMEDYST:ModeSelection','Error in Mode selection')
end

S.OperationMode = OperationMode;


%% GUI : Low / High reward

LowReward = str2double(get(handles.edit_LowReward,'String'));
if isempty(LowReward)
    error('LowReward is empty')
end
S.LowReward = LowReward;

HighReward = str2double(get(handles.edit_HighReward,'String'));
if isempty(HighReward)
    error('HighReward is empty')
end
S.HighReward = HighReward;


%% GUI : Starting sign

DeviationSign = get(handles.edit_DeviationSign,'String');
if isempty(DeviationSign)
    error('DeviationSign is empty')
end
S.DeviationSign = DeviationSign;


%% GUI + MAIN : Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');

if isempty(SubjectID)
    error('AMEDYST:SubjectIDLength','\n SubjectID is required \n')
end

% Prepare path
DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
end

% DataFile_noRun = sprintf('%s%s_%s_%s_%s', DataPath, S.TimeStampFile, SubjectID, Environement, Task );
DataFile_noRun = sprintf('%s_%s_%s', SubjectID, Environement, Task );

% Auto-incrementation of run number
% -----------------------------------------------------------------
% Fetch content of the directory
dirContent = dir(DataPath);

% Is there file of the previous run ?
previousRun = nan(length(dirContent)-2,1);
for f = 3 : length(dirContent) % avoid . and ..
    runNumber = regexp(dirContent(f).name,[DataFile_noRun '_run?(\d+)'],'tokens');
    if ~isempty(runNumber) % yes there is a file
        runNumber = runNumber{1}{:};
        previousRun(f) = str2double(runNumber); % save the previous run numbers
    else % no file found
        previousRun(f) = 0; % affect zero
    end
end

LastRunNumber = max(previousRun);
% If no previous run, LastRunNumber is 0
if isempty(LastRunNumber)
    LastRunNumber = 0;
end

RunNumber = LastRunNumber + 1;
% -----------------------------------------------------------------

switch DeviationSign
    case '+'
        sgn = 'Plus';
    case '-'
        sgn = 'Minus';
    otherwise
            error('DeviationSign')
end

DataFile     = sprintf('%s%s_%s_%s_%s_%s_run%0.2d', DataPath, S.TimeStampFile, SubjectID, Environement, Task, sgn, RunNumber );
DataFileName = sprintf(  '%s_%s_%s_%s_%s_run%0.2d',           S.TimeStampFile, SubjectID, Environement, Task, sgn, RunNumber  );

S.SubjectID     = SubjectID;
S.RunNumber     = RunNumber;
S.DataPath      = DataPath;
S.DataFile      = DataFile;
S.DataFileName  = DataFileName;


%% MAIN : Controls for SubjectID depending on the Mode selected

switch OperationMode
    
    case 'Acquisition'
        
        % Empty subject ID
        if isempty(SubjectID)
            error('AMEDYST:MissingSubjectID','\n For acquisition, SubjectID is required \n')
        end
        
        % Acquisition => save data
        if ~get(handles.radiobutton_SaveData,'Value')
            warning('AMEDYST:DataShouldBeSaved','\n\n\n In acquisition mode, data should be saved \n\n\n')
        end
        
end


%% GUI : Parallel port ?

switch get( handles.checkbox_ParPort , 'Value' )
    
    case 1
        ParPort = 'On';
    case 0
        ParPort = 'Off';
end
S.ParPort = ParPort;
S.ParPortMessages = Common.PrepareParPort;
handles.ParPort    = ParPort;


%% GUI : ADAPT : Show reward ?

switch Task
    
    case {'ADAPT_LowReward','ADAPT_HighReward'}
        
        Feedback = get( handles.checkbox_ATAPT_display_feedback , 'Value' );
        S.Feedback = Feedback;
        
end


%% GUI : SEQ : visual feedback ?

switch Task
    
    case 'SEQ'
        
        switch get(get(handles.uipanel_Feedback,'SelectedObject'),'Tag')
            case 'radiobutton_FeedbackOn'
                Feedback = 'On';
            case 'radiobutton_FeedbackOff'
                Feedback = 'Off';
            otherwise
                warning('AMEDYST:Feedback','Error in Feedback')
        end
        S.Feedback = Feedback;
        
end


%% GUI : ADAPT : input method ?

if isempty(get(handles.uipanel_CursorInput,'SelectedObject'))
    error('Select a cursor input method')
end

switch get(get(handles.uipanel_CursorInput,'SelectedObject'),'Tag')
    case 'radiobutton_Joystick'
        InputMethod = 'Joystick';
        joymex2('open',0);
        xmin_ymin_xmax_ymax = str2num( get(handles.edit_xmin_ymin_xmax_ymax, 'String') );
    case 'radiobutton_Mouse'
        InputMethod = 'Mouse';
    otherwise
        warning('AMEDYST:InputMethod','Error in InputMethod')
end

S.InputMethod = InputMethod;
S.xmin_ymin_xmax_ymax = xmin_ymin_xmax_ymax;


%% GUI : Check if Eyelink toolbox is available

switch get(get(handles.uipanel_EyelinkMode,'SelectedObject'),'Tag')
    
    case 'radiobutton_EyelinkOff'
        
        EyelinkMode = 'Off';
        
    case 'radiobutton_EyelinkOn'
        
        EyelinkMode = 'On';
        
        % 'Eyelink.m' exists ?
        status = which('Eyelink.m');
        if isempty(status)
            error('AMEDYST:EyelinkToolbox','no ''Eyelink.m'' detected in the path')
        end
        
        % Save mode ?
        if strcmp(S.SaveMode,'NoSave')
            error('AMEDYST:SaveModeForEyelink',' \n ---> Save mode should be turned on when using Eyelink <--- \n ')
        end
        
        % Eyelink connected ?
        Eyelink.IsConnected
        
        % File name for the eyelink : 8 char maximum
        switch Task
            case 'EyelinkCalibration'
                task = 'E'; % don't care...
            case 'SEQ'
                task = 'S';
            case {'ADAPT_LowReward','ADAPT_HighReward'}
                task = 'A';
            otherwise
                error('AMEDYST:Task','Task ?')
        end
        
        EyelinkFile_noRun = [ 'AD_' SubjectID task ];
        
        EyelinkFile = [EyelinkFile_noRun sprintf('%0.2d',RunNumber)];
        
        S.EyelinkFile = EyelinkFile;
        
    otherwise
        
        warning('AMEDYST:EyelinkMode','Error in Eyelink mode')
        
end

S.EyelinkMode = EyelinkMode;


%% MAIN : Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
end


%% MAIN : Get stimulation parameters

S.Parameters = GetParameters;

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
S.ScreenID = str2double( AvalableDisplays(SelectedDisplay) );


%% GUI : Windowed screen ?

switch get(handles.checkbox_WindowedScreen,'Value')
    
    case 1
        WindowedMode = 'On';
    case 0
        WindowedMode = 'Off';
    otherwise
        warning('AMEDYST:WindowedScreen','Error in WindowedScreen')
        
end

S.WindowedMode = WindowedMode;


%% MAIN : Open PTB window & sound

S.PTB = StartPTB;


%% MAIN : Task run

EchoStart(Task)

switch Task
    
    case 'SEQ'
        TaskData = SEQ.Task;
        
    case {'ADAPT_LowReward','ADAPT_HighReward'}
        TaskData = ADAPT.Task;
        
    case 'EyelinkCalibration'
        Eyelink.Calibration(S.PTB.wPtr);
        TaskData.ER.Data = {};
        
    otherwise
        error('AMEDYST:Task','Task ?')
end

EchoStop(Task)

S.TaskData = TaskData;


%% MAIN : Save files on the fly : just a security in case of crash of the end the script

save([fileparts(pwd) filesep 'data' filesep 'LastS'],'S');


%% MAIN : Close PTB

sca;
Priority( 0 );


%% MAIN : SPM data organization

[ names , onsets , durations ] = SPMnod;


%% MAIN : perform stats computation

if strcmp(Task,'SEQ')
    
    printResults(S.TaskData.ER)
    
elseif any(strcmp(Task,{'ADAPT_LowReward','ADAPT_HighReward'}))
    
    if ~isempty(S.TaskData.OutRecorder.Data)
        
        S.Stats.evolution_RT_TT_inBlock            = ADAPT.Stats.evolution_RT_TT_inBlock;
        S.Stats.   global_RT_TT_inBlock            = ADAPT.Stats.   global_RT_TT_inBlock;
        S.Stats.evolution_AUC_inBlock              = ADAPT.Stats.evolution_AUC_inBlock;
        S.Stats.   global_AUC_inBlock              = ADAPT.Stats.   global_AUC_inBlock;
        S.Stats.evolution_RT_TT_AUC_inRewardChance = ADAPT.Stats.evolution_RT_TT_AUC_inRewardChance;
        S.Stats.evolution_RT_TT_AUC_inTarget       = ADAPT.Stats.evolution_RT_TT_AUC_inTarget;
        
        % Plot 
        switch OperationMode
            case 'Acquisition'
            case 'FastDebug'
                ADAPT.Stats.PLOT_ALL( S )
            case 'RealisticDebug'
                ADAPT.Stats.PLOT_ALL( S )
        end % switch
        
    end
    
    fprintf('UnitGain for this run     : %g € \n', S.TaskData.Parameters.UnitGain);
    fprintf('Total reward for this run : %g € \n', S.TaskData.Parameters.TotalReward);
    
end


%% MAIN : Saving data strucure

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
    save(DataFile,     'S', 'names', 'onsets', 'durations');
    save([DataFile '_SPM'], 'names', 'onsets', 'durations');
    
end


%% MAIN : Send S and SPM nod to workspace

assignin('base', 'S'        , S        );
assignin('base', 'names'    , names    );
assignin('base', 'onsets'   , onsets   );
assignin('base', 'durations', durations);


%% MAIN : End recording of Eyelink

% Eyelink mode 'On' ?
if strcmp(S.EyelinkMode,'On')
    
    % Stop recording and retrieve the file
    Eyelink.StopRecording( S.EyelinkFile , S.DataPath )
    
    if ~strcmp(S.Task,'EyelinkCalibration')
        
        % Rename the file
        movefile([S.DataPath EyelinkFile '.edf'], [S.DataFile '.edf'])
        
    end
    
end


%% MAIN + GUI : Ready for another run

set(handles.text_LastFileNameAnnouncer, 'Visible','on'                             )
set(handles.text_LastFileName         , 'Visible','on'                             )
set(handles.text_LastFileName         , 'String' , DataFile(length(DataPath)+1:end))

WaitSecs(0.100);
pause(0.100);
fprintf('\n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')
fprintf('  Ready for another session   \n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')


end % function
