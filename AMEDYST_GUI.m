function varargout = AMEDYST_GUI
% AMEDYST_GUI is the function that creates (or bring to focus) AMEDYST GUI.
% Then, AMEDYST_main is always called to start each task. It is the
% "main" program.

% debug=1 closes previous figure and reopens it, and send the gui handles
% to base workspace.
debug = 0;


%% Open a singleton figure, or gring the actual into focus.

% Is the GUI already open ?
figPtr = findall(0,'Tag',mfilename);

if ~isempty(figPtr) % Figure exists so brings it to the focus
    
    figure(figPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        close(figPtr); %#ok<UNRCH>
        AMEDYST_GUI;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
else % Create the figure
    
    clc
    rng('default')
    rng('shuffle')
    
    % Create a figure
    figHandle = figure( ...
        'HandleVisibility', 'off',... % close all does not close the figure
        'MenuBar'         , 'none'                   , ...
        'Toolbar'         , 'none'                   , ...
        'Name'            , mfilename                , ...
        'NumberTitle'     , 'off'                    , ...
        'Units'           , 'Pixels'                 , ...
        'Position'        , [20, 20, 700, 700] , ...
        'Tag'             , mfilename                );
    
    figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
    buttonBGcolor = figureBGcolor - 0.1;
    editBGcolor   = [1.0 1.0 1.0];
    
    % Create GUI handles : pointers to access the graphic objects
    handles = guihandles(figHandle);
    
    
    %% Default values for Low reward & High reward
    
    handles.defaultLowRreward  = 06.4;
    handles.defaultHighRreward = 32.0;
    
    
    %% Panel proportions
    
    panelProp.xposP = 0.05; % xposition of panel normalized : from 0 to 1
    panelProp.wP    = 1 - panelProp.xposP * 2;
    
    panelProp.vect  = ...
        [1 4 2 1 1 2 ]; % relative proportions of each panel, from bottom to top
    
    panelProp.vectLength    = length(panelProp.vect);
    panelProp.vectTotal     = sum(panelProp.vect);
    panelProp.adjustedTotal = panelProp.vectTotal + 1;
    panelProp.unitWidth     = 1/panelProp.adjustedTotal;
    panelProp.interWidth    = panelProp.unitWidth/panelProp.vectLength;
    
    panelProp.countP = panelProp.vectLength + 1;
    panelProp.yposP  = @(countP) panelProp.unitWidth*sum(panelProp.vect(1:countP-1)) + 0.8*countP*panelProp.interWidth;
    
    
    %% Panel : Subject & Run
    
    p_sr.x = panelProp.xposP;
    p_sr.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_sr.y = panelProp.yposP(panelProp.countP);
    p_sr.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_SubjectRun = uipanel(handles.(mfilename),...
        'Title','Subject & Run',...
        'Units', 'Normalized',...
        'Position',[p_sr.x p_sr.y p_sr.w p_sr.h],...
        'BackgroundColor',figureBGcolor);
    
    p_sr.nbO       = 3; % Number of objects
    p_sr.Ow        = 1/(p_sr.nbO + 1); % Object width
    p_sr.countO    = 0; % Object counter
    p_sr.xposO     = @(countO) p_sr.Ow/(p_sr.nbO+1)*countO + (countO-1)*p_sr.Ow;
    p_sr.yposOmain = 0.1;
    p_sr.hOmain    = 0.6;
    p_sr.yposOhdr  = 0.7;
    p_sr.hOhdr     = 0.2;
    
    
    % ---------------------------------------------------------------------
    % Edit : Subject ID
    
    p_sr.countO = p_sr.countO + 1;
    e_sid.x = p_sr.xposO(p_sr.countO);
    e_sid.y = p_sr.yposOmain ;
    e_sid.w = p_sr.Ow;
    e_sid.h = p_sr.hOmain;
    handles.edit_SubjectID = uicontrol(handles.uipanel_SubjectRun,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_sid.x e_sid.y e_sid.w e_sid.h],...
        'BackgroundColor',editBGcolor,...
        'String','',...
        'Callback',@edit_SubjectID_Callback);
    
    
    % ---------------------------------------------------------------------
    % Text : Subject ID
    
    t_sid.x = p_sr.xposO(p_sr.countO);
    t_sid.y = p_sr.yposOhdr ;
    t_sid.w = p_sr.Ow;
    t_sid.h = p_sr.hOhdr;
    handles.text_SubjectID = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sid.x t_sid.y t_sid.w t_sid.h],...
        'String','Subject ID',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Check SubjectID data
    
    p_sr.countO = p_sr.countO + 1;
    b_csidd.x = p_sr.xposO(p_sr.countO);
    b_csidd.y = p_sr.yposOmain;
    b_csidd.w = p_sr.Ow;
    b_csidd.h = p_sr.hOmain;
    handles.pushbutton_Check_SubjectID_data = uicontrol(handles.uipanel_SubjectRun,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_csidd.x b_csidd.y b_csidd.w b_csidd.h],...
        'String','Check SubjectID data',...
        'BackgroundColor',buttonBGcolor,...
        'TooltipString','Display in Command Window the content of data/(SubjectID)',...
        'Callback',@(hObject,eventdata)GUI.Pushbutton_Check_SubjectID_data_Callback(handles.edit_SubjectID,eventdata));
    
    
    % ---------------------------------------------------------------------
    % Text : Last file name annoucer
    
    p_sr.countO = p_sr.countO + 1;
    t_lfna.x = p_sr.xposO(p_sr.countO);
    t_lfna.y = p_sr.yposOhdr ;
    t_lfna.w = p_sr.Ow;
    t_lfna.h = p_sr.hOhdr;
    handles.text_LastFileNameAnnouncer = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_lfna.x t_lfna.y t_lfna.w t_lfna.h],...
        'String','Last file name',...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    % ---------------------------------------------------------------------
    % Text : Last file name
    
    t_lfn.x = p_sr.xposO(p_sr.countO);
    t_lfn.y = p_sr.yposOmain ;
    t_lfn.w = p_sr.Ow;
    t_lfn.h = p_sr.hOmain;
    handles.text_LastFileName = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_lfn.x t_lfn.y t_lfn.w t_lfn.h],...
        'String','',...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    %% Panel : Save mode
    
    p_sm.x = panelProp.xposP;
    p_sm.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_sm.y = panelProp.yposP(panelProp.countP);
    p_sm.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_SaveMode = uibuttongroup(handles.(mfilename),...
        'Title','Save mode',...
        'Units', 'Normalized',...
        'Position',[p_sm.x p_sm.y p_sm.w p_sm.h],...
        'BackgroundColor',figureBGcolor);
    
    p_sm.nbO    = 2; % Number of objects
    p_sm.Ow     = 1/(p_sm.nbO + 1); % Object width
    p_sm.countO = 0; % Object counter
    p_sm.xposO  = @(countO) p_sm.Ow/(p_sm.nbO+1)*countO + (countO-1)*p_sm.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Save Data
    
    p_sm.countO = p_sm.countO + 1;
    r_sd.x   = p_sm.xposO(p_sm.countO);
    r_sd.y   = 0.1 ;
    r_sd.w   = p_sm.Ow;
    r_sd.h   = 0.8;
    r_sd.tag = 'radiobutton_SaveData';
    handles.(r_sd.tag) = uicontrol(handles.uipanel_SaveMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_sd.x r_sd.y r_sd.w r_sd.h],...
        'String','Save data',...
        'TooltipString','Save data to : ../data/SubjectID/...',...
        'HorizontalAlignment','Center',...
        'Tag',r_sd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : No save
    
    p_sm.countO = p_sm.countO + 1;
    r_ns.x   = p_sm.xposO(p_sm.countO);
    r_ns.y   = 0.1 ;
    r_ns.w   = p_sm.Ow;
    r_ns.h   = 0.8;
    r_ns.tag = 'radiobutton_NoSave';
    handles.(r_ns.tag) = uicontrol(handles.uipanel_SaveMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_ns.x r_ns.y r_ns.w r_ns.h],...
        'String','No save',...
        'TooltipString','In Acquisition mode, Save mode must be engaged',...
        'HorizontalAlignment','Center',...
        'Tag',r_ns.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Environement
    
    p_env.x = panelProp.xposP;
    p_env.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_env.y = panelProp.yposP(panelProp.countP);
    p_env.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Environement = uibuttongroup(handles.(mfilename),...
        'Title','Environement : key mapping',...
        'Units', 'Normalized',...
        'Position',[p_env.x p_env.y p_env.w p_env.h],...
        'BackgroundColor',figureBGcolor);
    
    p_env.nbO    = 2; % Number of objects
    p_env.Ow     = 1/(p_env.nbO + 1); % Object width
    p_env.countO = 0; % Object counter
    p_env.xposO  = @(countO) p_env.Ow/(p_env.nbO+1)*countO + (countO-1)*p_env.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : MRI
    
    p_env.countO = p_env.countO + 1;
    r_mri.x   = p_env.xposO(p_env.countO);
    r_mri.y   = 0.1 ;
    r_mri.w   = p_env.Ow;
    r_mri.h   = 0.8;
    r_mri.tag = 'radiobutton_MRI';
    handles.(r_mri.tag) = uicontrol(handles.uipanel_Environement,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_mri.x r_mri.y r_mri.w r_mri.h],...
        'String','MRI',...
        'TooltipString','Response buttons (fORP)',...
        'HorizontalAlignment','Center',...
        'Tag',(r_mri.tag),...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Practice
    
    p_env.countO = p_env.countO + 1;
    r_practice.x   = p_env.xposO(p_env.countO);
    r_practice.y   = 0.1 ;
    r_practice.w   = p_env.Ow;
    r_practice.h   = 0.8;
    r_practice.tag = 'radiobutton_Practice';
    handles.(r_practice.tag) = uicontrol(handles.uipanel_Environement,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_practice.x r_practice.y r_practice.w r_practice.h],...
        'String','Practice',...
        'TooltipString','keyboard keys',...
        'HorizontalAlignment','Center',...
        'Tag',(r_practice.tag),...
        'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Eyelink mode
    
    el_shift = 0.30;
    
    p_el.x = panelProp.xposP + el_shift;
    p_el.w = panelProp.wP - el_shift ;
    
    panelProp.countP = panelProp.countP - 1;
    p_el.y = panelProp.yposP(panelProp.countP);
    p_el.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_EyelinkMode = uibuttongroup(handles.(mfilename),...
        'Title','Eyelink mode',...
        'Units', 'Normalized',...
        'Position',[p_el.x p_el.y p_el.w p_el.h],...
        'BackgroundColor',figureBGcolor,...
        'SelectionChangeFcn',@uipanel_EyelinkMode_SelectionChangeFcn);
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Windowed screen
    
    c_ws.x = panelProp.xposP;
    c_ws.w = el_shift - panelProp.xposP;
    
    c_ws.y = panelProp.yposP(panelProp.countP)-0.01 ;
    c_ws.h = p_el.h * 0.3;
    
    handles.checkbox_WindowedScreen = uicontrol(handles.(mfilename),...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_ws.x c_ws.y c_ws.w c_ws.h],...
        'String','Windowed screen',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Listbox : Screens
    
    l_sc.x = panelProp.xposP;
    l_sc.w = el_shift - panelProp.xposP;
    
    l_sc.y = c_ws.y + c_ws.h ;
    l_sc.h = p_el.h * 0.6;
    
    handles.listbox_Screens = uicontrol(handles.(mfilename),...
        'Style','listbox',...
        'Units', 'Normalized',...
        'Position',[l_sc.x l_sc.y l_sc.w l_sc.h],...
        'String',{'a' 'b' 'c'},...
        'TooltipString','Select the display mode   PTB : 0 for extended display (over all screens) , 1 for screen 1 , 2 for screen 2 , etc.',...
        'HorizontalAlignment','Center',...
        'CreateFcn',@GUI.Listbox_Screens_CreateFcn);
    
    
    % ---------------------------------------------------------------------
    % Text : ScreenMode
    
    t_sm.x = panelProp.xposP;
    t_sm.w = el_shift - panelProp.xposP;
    
    t_sm.y = l_sc.y + l_sc.h ;
    t_sm.h = p_el.h * 0.15;
    
    handles.text_ScreenMode = uicontrol(handles.(mfilename),...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sm.x t_sm.y t_sm.w t_sm.h],...
        'String','Screen mode selection',...
        'TooltipString','Output of Screen(''Screens'')   Use ''Screen Screens?'' in Command window for help',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_el_up.nbO    = 6; % Number of objects
    p_el_up.Ow     = 1/(p_el_up.nbO + 1); % Object width
    p_el_up.countO = 0; % Object counter
    p_el_up.xposO  = @(countO) p_el_up.Ow/(p_el_up.nbO+1)*countO + (countO-1)*p_el_up.Ow;
    p_el_up.y      = 0.6;
    p_el_up.h      = 0.3;
    
    % ---------------------------------------------------------------------
    % RadioButton : Eyelink ON
    
    p_el_up.countO = p_el_up.countO + 1;
    r_elon.x   = p_el_up.xposO(p_el_up.countO);
    r_elon.y   = p_el_up.y ;
    r_elon.w   = p_el_up.Ow;
    r_elon.h   = p_el_up.h;
    r_elon.tag = 'radiobutton_EyelinkOn';
    handles.(r_elon.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_elon.x r_elon.y r_elon.w r_elon.h],...
        'String','On',...
        'HorizontalAlignment','Center',...
        'Tag',r_elon.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','On');
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Eyelink OFF
    
    p_el_up.countO = p_el_up.countO + 1;
    r_eloff.x   = p_el_up.xposO(p_el_up.countO);
    r_eloff.y   = p_el_up.y ;
    r_eloff.w   = p_el_up.Ow;
    r_eloff.h   = p_el_up.h;
    r_eloff.tag = 'radiobutton_EyelinkOff';
    handles.(r_eloff.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_eloff.x r_eloff.y r_eloff.w r_eloff.h],...
        'String','Off',...
        'HorizontalAlignment','Center',...
        'Tag',r_eloff.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','On');
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Parallel port
    
    p_el_up.countO = p_el_up.countO + 1;
    c_pp.x = p_el_up.xposO(p_el_up.countO);
    c_pp.y = p_el_up.y ;
    c_pp.w = p_el_up.Ow*2;
    c_pp.h = p_el_up.h;
    handles.checkbox_ParPort = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_pp.x c_pp.y c_pp.w c_pp.h],...
        'String','Parallel port',...
        'HorizontalAlignment','Center',...
        'TooltipString','Send messages via parallel port : useful for Eyelink',...
        'BackgroundColor',figureBGcolor,...
        'Value',1,...
        'Callback',@GUI.Checkbox_ParPort_Callback,...
        'CreateFcn',@GUI.Checkbox_ParPort_Callback);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_el_dw.nbO    = 3; % Number of objects
    p_el_dw.Ow     = 1/(p_el_dw.nbO + 1); % Object width
    p_el_dw.countO = 0; % Object counter
    p_el_dw.xposO  = @(countO) p_el_dw.Ow/(p_el_dw.nbO+1)*countO + (countO-1)*p_el_dw.Ow;
    p_el_dw.y      = 0.1;
    p_el_dw.h      = 0.4 ;
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Initialize
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_init.x = p_el_dw.xposO(p_el_dw.countO);
    b_init.y = p_el_dw.y ;
    b_init.w = p_el_dw.Ow;
    b_init.h = p_el_dw.h;
    handles.pushbutton_Initialize = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_init.x b_init.y b_init.w b_init.h],...
        'String','Initialize',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.Initialize');
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink IsConnected
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_isco.x = p_el_dw.xposO(p_el_dw.countO);
    b_isco.y = p_el_dw.y ;
    b_isco.w = p_el_dw.Ow;
    b_isco.h = p_el_dw.h;
    handles.pushbutton_IsConnected = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_isco.x b_isco.y b_isco.w b_isco.h],...
        'String','IsConnected',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.IsConnected');
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Calibration
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_cal.x   = p_el_dw.xposO(p_el_dw.countO);
    b_cal.y   = p_el_dw.y ;
    b_cal.w   = p_el_dw.Ow;
    b_cal.h   = p_el_dw.h;
    b_cal.tag = 'pushbutton_EyelinkCalibration';
    handles.(b_cal.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_cal.x b_cal.y b_cal.w b_cal.h],...
        'String','Calibration',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_cal.tag,...
        'Callback',@AMEDYST_main);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink force shutdown
    
    b_fsd.x = c_pp.x + c_pp.h;
    b_fsd.y = p_el_up.y ;
    b_fsd.w = p_el_dw.Ow*1.25;
    b_fsd.h = p_el_dw.h;
    handles.pushbutton_ForceShutDown = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_fsd.x b_fsd.y b_fsd.w b_fsd.h],...
        'String','ForceShutDown',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.ForceShutDown');
    
    
    %% Panel : Task : ADAPT
    
    %     p_tk_adapt.x = p_tk_seq.x + p_tk_seq.w + p_tk_x_spacing;
    %     p_tk_adapt.w = p_tk_seq.w*2 ;
    p_tk_adapt.x = panelProp.xposP;
    p_tk_adapt.w = panelProp.wP;
    
    
    panelProp.countP = panelProp.countP - 1;
    p_tk_adapt.y = panelProp.yposP(panelProp.countP);
    p_tk_adapt.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Task_ADAPT = uibuttongroup(handles.(mfilename),...
        'Title','ADAPT',...
        'Units', 'Normalized',...
        'Position',[p_tk_adapt.x p_tk_adapt.y p_tk_adapt.w p_tk_adapt.h],...
        'BackgroundColor',figureBGcolor);
    
    p_tk_adapt.nbO    = 5; % Number of objects
    p_tk_adapt.Ow     = 1/(p_tk_adapt.nbO + 1); % Object width
    p_tk_adapt.countO = 0; % Object counter
    p_tk_adapt.xposO  = @(countO) p_tk_adapt.Ow/(p_tk_adapt.nbO+1)*countO + (countO-1)*p_tk_adapt.Ow;
    
    p_tk_adapt.y_marge = 0.05;
    
    
    % ---------------------------------------------------------------------
    % Edit : Deviation signe +/-
    
    p_tk_adapt.countO = p_tk_adapt.countO + 1;
    e_deviation_sign.x = p_tk_adapt.xposO(p_tk_adapt.countO);
    e_deviation_sign.y = p_tk_adapt.y_marge;
    e_deviation_sign.w = p_tk_adapt.Ow;
    e_deviation_sign.h = 0.4 - p_tk_adapt.y_marge;
    handles.edit_DeviationSign = uicontrol(handles.uipanel_Task_ADAPT,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_deviation_sign.x e_deviation_sign.y e_deviation_sign.w e_deviation_sign.h],...
        'BackgroundColor',editBGcolor,...
        'String','',...
        'Callback',@edit_DeviationSign_Callback,...
        'Tooltip','can only be + or -');
    
    % ---------------------------------------------------------------------
    % Edit : High Reward
    
    p_tk_adapt.countO = p_tk_adapt.countO + 1;
    e_high_reward.x = p_tk_adapt.xposO(p_tk_adapt.countO);
    e_high_reward.y = p_tk_adapt.y_marge;
    e_high_reward.w = p_tk_adapt.Ow;
    e_high_reward.h = 0.15;
    handles.edit_HighReward = uicontrol(handles.uipanel_Task_ADAPT,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_high_reward.x e_high_reward.y e_high_reward.w e_high_reward.h],...
        'BackgroundColor',editBGcolor,...
        'String',num2str(handles.defaultHighRreward),...
        'Callback',@edit_HighReward_Callback,...
        'Tooltip','High reward (€)');
    
    
    % ---------------------------------------------------------------------
    % Edit : Low Reward
    
    e_low_reward.x = p_tk_adapt.xposO(p_tk_adapt.countO);
    e_low_reward.y = e_high_reward.h + e_high_reward.y + p_tk_adapt.y_marge;
    e_low_reward.w = p_tk_adapt.Ow;
    e_low_reward.h = e_high_reward.h;
    handles.edit_LowReward = uicontrol(handles.uipanel_Task_ADAPT,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_low_reward.x e_low_reward.y e_low_reward.w e_low_reward.h],...
        'BackgroundColor',editBGcolor,...
        'String',num2str(handles.defaultLowRreward),...
        'Callback',@edit_LowReward_Callback,...
        'Tooltip','Low reward (€)');
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : ADAPT_HighReward
    
    p_tk_adapt.countO  = p_tk_adapt.countO + 1;
    b_adapt_high.x   = p_tk_adapt.xposO(p_tk_adapt.countO);
    b_adapt_high.y   = p_tk_adapt.y_marge;
    b_adapt_high.w   = p_tk_adapt.Ow*2;
    b_adapt_high.h   = e_high_reward.h;
    b_adapt_high.tag = 'pushbutton_ADAPT_HighReward';
    handles.(b_adapt_high.tag) = uicontrol(handles.uipanel_Task_ADAPT,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_adapt_high.x b_adapt_high.y b_adapt_high.w b_adapt_high.h],...
        'String','ADAPT : High reward',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_adapt_high.tag,...
        'Callback',@AMEDYST_main,...
        'FontSize',8);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : ADAPT_LowReward
    
    b_adapt_low.x   = p_tk_adapt.xposO(p_tk_adapt.countO);
    b_adapt_low.y   = e_low_reward.y;
    b_adapt_low.w   = b_adapt_high.w;
    b_adapt_low.h   = e_high_reward.h;
    b_adapt_low.tag = 'pushbutton_ADAPT_LowReward';
    handles.(b_adapt_low.tag) = uicontrol(handles.uipanel_Task_ADAPT,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_adapt_low.x b_adapt_low.y b_adapt_low.w b_adapt_low.h],...
        'String','ADAPT : Low reward',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_adapt_low.tag,...
        'Callback',@AMEDYST_main,...
        'FontSize',8);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : PLOT_ALL
    
    p_tk_adapt.countO  = p_tk_adapt.countO + 2;
    b_PLOT_ALL.x   = p_tk_adapt.xposO(p_tk_adapt.countO);
    b_PLOT_ALL.y   = p_tk_adapt.y_marge;
    b_PLOT_ALL.w   = p_tk_adapt.Ow;
    b_PLOT_ALL.h   = e_deviation_sign.h;
    b_PLOT_ALL.tag = 'pushbutton_PLOT_ALL';
    handles.(b_PLOT_ALL.tag) = uicontrol(handles.uipanel_Task_ADAPT,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_PLOT_ALL.x b_PLOT_ALL.y b_PLOT_ALL.w b_PLOT_ALL.h],...
        'String','plot_stats',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_PLOT_ALL.tag,...
        'Callback',@pushbutton_PLOT_ALL_GUIroutine,...
        'ButtonDownFcn',@pushbutton_PLOT_ALL_GUIroutine,...
        'FontSize',8,...
        'Tooltip','Left click : plot last data  //  Right click : open UI to load specific data');
    
    
    %% Panel : Cursor input method
    
    p_cursorinput.x = panelProp.xposP;
    p_cursorinput.w = panelProp.wP*2/3;
    
    p_cursorinput.y = b_adapt_low.y + b_adapt_low.h + p_tk_adapt.y_marge;
    p_cursorinput.h = 1 - p_cursorinput.y - p_tk_adapt.y_marge;
    
    handles.uipanel_CursorInput = uibuttongroup(handles.uipanel_Task_ADAPT,...
        'Title','Cursor input method',...
        'TitlePosition','righttop',...
        'Units', 'Normalized',...
        'Position',[p_cursorinput.x p_cursorinput.y p_cursorinput.w p_cursorinput.h],...
        'BackgroundColor',figureBGcolor,...
        'SelectionChangeFcn',@uipanel_CursorInput_SelectionChangeFcn);
    
    
    p_cursorinput.nbO    = 3; % Number of objects
    p_cursorinput.Ow     = 1/(p_cursorinput.nbO + 1); % Object width
    p_cursorinput.countO = 0; % Object counter
    p_cursorinput.xposO  = @(countO) p_cursorinput.Ow/(p_cursorinput.nbO+1)*countO + (countO-1)*p_cursorinput.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Joystick
    
    p_cursorinput.countO = p_cursorinput.countO + 1;
    r_joystick.x   = p_cursorinput.xposO(p_cursorinput.countO);
    r_joystick.y   = 0.5;
    r_joystick.w   = p_cursorinput.Ow;
    r_joystick.h   = 0.4;
    r_joystick.tag = 'radiobutton_Joystick';
    handles.(r_joystick.tag) = uicontrol(handles.uipanel_CursorInput,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_joystick.x r_joystick.y r_joystick.w r_joystick.h],...
        'String','Joystick',...
        'HorizontalAlignment','Center',...
        'Tag',r_joystick.tag,...
        'BackgroundColor',figureBGcolor,...
        'ButtonDownFcn','joymex2_test',...
        'Tooltip','Right click will open a test');
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Joystick calibration
    
    p_cursorinput.countO = p_cursorinput.countO + 1;
    p_joycal.x   = p_cursorinput.xposO(p_cursorinput.countO);
    p_joycal.y   = 0.5;
    p_joycal.w   = p_cursorinput.Ow;
    p_joycal.h   = 0.4;
    p_joycal.tag = 'pushbutton_JoystickCalibration';
    handles.(p_joycal.tag) = uicontrol(handles.uipanel_CursorInput,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[p_joycal.x p_joycal.y p_joycal.w p_joycal.h],...
        'String','JCalibration',...
        'HorizontalAlignment','Center',...
        'Tag',p_joycal.tag,...
        'BackgroundColor',figureBGcolor,...
        'Callback',@joystick_calibration,...
        'Visible', 'off');
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Mouse
    
    p_cursorinput.countO = p_cursorinput.countO + 1;
    r_mouse.x   = p_cursorinput.xposO(p_cursorinput.countO);
    r_mouse.y   = 0.5;
    r_mouse.w   = p_cursorinput.Ow;
    r_mouse.h   = 0.4;
    r_mouse.tag = 'radiobutton_Mouse';
    handles.(r_mouse.tag) = uicontrol(handles.uipanel_CursorInput,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_mouse.x r_mouse.y r_mouse.w r_mouse.h],...
        'String','Mouse',...
        'HorizontalAlignment','Center',...
        'Tag',r_mouse.tag,...
        'BackgroundColor',figureBGcolor);
    
    % Uncheck the button : this is my way to force the user to select a method
    set(handles.uipanel_CursorInput,'SelectedObject','')
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Display Feedback
    
    c_fb.x = panelProp.wP*3/4;
    c_fb.y = p_cursorinput.y;
    c_fb.w = panelProp.wP*1/3;
    c_fb.h = p_cursorinput.h;
    handles.checkbox_ATAPT_display_feedback = uicontrol(handles.uipanel_Task_ADAPT,...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_fb.x c_fb.y c_fb.w c_fb.h],...
        'String','Show Reward',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor,...
        'Value',1,...
        'Tooltip','Show reward probability & result');
    
    
    % ---------------------------------------------------------------------
    % edit : xmin xmax ymin ymax
    
    e_xymm.x = 0.1;
    e_xymm.w = 0.8;
    e_xymm.y = 0.1;
    e_xymm.h = 0.4;
    e_xymm.tag = 'edit_xmin_ymin_xmax_ymax';
    handles.(e_xymm.tag) = uicontrol(handles.uipanel_CursorInput,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_xymm.x e_xymm.y e_xymm.w e_xymm.h],...
        'BackgroundColor',editBGcolor,...
        'String','',...
        'Visible', 'off',...
        'Tooltip','Set with joystick calibration');
    
    
    %% Panel : Operation mode
    
    p_op.x = panelProp.xposP;
    p_op.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_op.y = panelProp.yposP(panelProp.countP);
    p_op.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_OperationMode = uibuttongroup(handles.(mfilename),...
        'Title','Operation mode',...
        'Units', 'Normalized',...
        'Position',[p_op.x p_op.y p_op.w p_op.h],...
        'BackgroundColor',figureBGcolor);
    
    p_op.nbO    = 3; % Number of objects
    p_op.Ow     = 1/(p_op.nbO + 1); % Object width
    p_op.countO = 0; % Object counter
    p_op.xposO  = @(countO) p_op.Ow/(p_op.nbO+1)*countO + (countO-1)*p_op.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Acquisition
    
    p_op.countO = p_op.countO + 1;
    r_aq.x = p_op.xposO(p_op.countO);
    r_aq.y = 0.1 ;
    r_aq.w = p_op.Ow;
    r_aq.h = 0.8;
    r_aq.tag = 'radiobutton_Acquisition';
    handles.(r_aq.tag) = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_aq.x r_aq.y r_aq.w r_aq.h],...
        'String','Acquisition',...
        'TooltipString','Should be used for all the environements',...
        'HorizontalAlignment','Center',...
        'Tag',r_aq.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : FastDebug
    
    p_op.countO = p_op.countO + 1;
    r_fd.x   = p_op.xposO(p_op.countO);
    r_fd.y   = 0.1 ;
    r_fd.w   = p_op.Ow;
    r_fd.h   = 0.8;
    r_fd.tag = 'radiobutton_FastDebug';
    handles.radiobutton_FastDebug = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_fd.x r_fd.y r_fd.w r_fd.h],...
        'String','FastDebug',...
        'TooltipString','Only to work on the scripts',...
        'HorizontalAlignment','Center',...
        'Tag',r_fd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : RealisticDebug
    
    p_op.countO = p_op.countO + 1;
    r_rd.x   = p_op.xposO(p_op.countO);
    r_rd.y   = 0.1 ;
    r_rd.w   = p_op.Ow;
    r_rd.h   = 0.8;
    r_rd.tag = 'radiobutton_RealisticDebug';
    handles.(r_rd.tag) = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_rd.x r_rd.y r_rd.w r_rd.h],...
        'String','RealisticDebug',...
        'TooltipString','Only to work on the scripts',...
        'HorizontalAlignment','Center',...
        'Tag',r_rd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        assignin('base','handles',handles) %#ok<UNRCH>
        disp(handles)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figPtr = figHandle;
    
    fprintf('\n')
    fprintf('Response buttuns (fORRP 932) : \n')
    fprintf('\n')
    fprintf('1) SEQ :\n')
    fprintf('USB \n')
    fprintf('HHSC - 2x4 - C \n')
    fprintf('HID NAR BYGRT \n')
    fprintf('\n')
    fprintf('1) ADAPT :\n')
    fprintf('USB \n')
    fprintf('TETHYX \n')
    fprintf('HID JOYSTICK \n')
    fprintf('\n')
    
    
end

if nargout > 0
    
    varargout{1} = guidata(figPtr);
    
end


end % function


%% GUI Functions

% -------------------------------------------------------------------------
function edit_SubjectID_Callback(hObject, ~)

NrChar = 2;

id_str = get(hObject,'String');

if length(id_str) ~= NrChar
    set(hObject,'String','')
    error('SubjectID must be %d chars', NrChar)
end

fprintf('SubjectID OK : %s \n', id_str)

end % function


% -------------------------------------------------------------------------
% function edit_Seqeunce_Callback(hObject, ~)
%
% NrTap = 8;
%
% sequence_str = get(hObject,'String');
%
% if length(sequence_str) ~= NrTap
%     set(hObject,'String','')
%     error('ComplexSequence must be %d non consecutive numbers', NrTap)
% end
%
% sequence_vect = (  cellstr(sequence_str')' );
% sequence_vect = cellfun(@str2double,sequence_vect);
% if any(sequence_vect > 5  |  sequence_vect < 2  |  round(sequence_vect) ~= sequence_vect)
%     set(hObject,'String','')
%     error('ComplexSequence must be numbers from 2 to 5 (positive integers)')
% end
%
% if any( diff(sequence_vect) == 0 )
%     set(hObject,'String','')
%     error('ComplexSequence not have two identical consecutive numbers')
% end
%
% fprintf('ComplexSequence OK : %s \n', sequence_str)
%
% end % function


% -------------------------------------------------------------------------
function uipanel_EyelinkMode_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton_EyelinkOff'
        set(handles.pushbutton_EyelinkCalibration,'Visible','off')
        set(handles.pushbutton_IsConnected       ,'Visible','off')
        set(handles.pushbutton_ForceShutDown     ,'Visible','off')
        set(handles.pushbutton_Initialize        ,'Visible','off')
    case 'radiobutton_EyelinkOn'
        set(handles.pushbutton_EyelinkCalibration,'Visible','on')
        set(handles.pushbutton_IsConnected       ,'Visible','on')
        set(handles.pushbutton_ForceShutDown     ,'Visible','on')
        set(handles.pushbutton_Initialize        ,'Visible','on')
end

end % function


% -------------------------------------------------------------------------
function uipanel_CursorInput_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);

% Check if joymex2 exists in the path
if isempty( which('joymex2') )
    disp('joymex2 NOT DETECTED : check https://github.com/escabe/joymex2')
    set(hObject,'SelectedObject',handles.radiobutton_Mouse);
    set(handles.pushbutton_JoystickCalibration, 'Visible', 'off')
    set(handles.edit_xmin_ymin_xmax_ymax, 'Visible', 'off')
end

try
    switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
        case 'radiobutton_Joystick'
            joymex2('open',0);
            set(handles.pushbutton_JoystickCalibration, 'Visible', 'on')
            set(handles.edit_xmin_ymin_xmax_ymax, 'Visible', 'on')
        case 'radiobutton_Mouse'
            % joymex2('close',0);
            clear joymex2 % more stable on linux than "joymex2('close',0);"
            set(handles.pushbutton_JoystickCalibration, 'Visible', 'off')
            set(handles.edit_xmin_ymin_xmax_ymax, 'Visible', 'off')
    end
    
catch err
    set(hObject,'SelectedObject',handles.radiobutton_Mouse);
    set(handles.pushbutton_JoystickCalibration, 'Visible', 'off')
    set(handles.edit_xmin_ymin_xmax_ymax, 'Visible', 'off')
    rethrow(err)
end

end % function


% -------------------------------------------------------------------------
function edit_HighReward_Callback(hObject, ~)
handles = guidata(hObject);

HighReward = str2double(get(hObject,'String'));

if isnumeric(HighReward) && isscalar(HighReward) && ~isnan(HighReward)
    fprintf('High reward ok : %g € \n', HighReward)
else
    set(hObject,'String',num2str(handles.defaultHighRreward))
    error('High reward must be scalar value')
end

end % function


% -------------------------------------------------------------------------
function edit_LowReward_Callback(hObject, ~)
handles = guidata(hObject);

LowReward = str2double(get(hObject,'String'));

if isnumeric(LowReward) && isscalar(LowReward) && ~isnan(LowReward)
    fprintf('Low reward ok : %g € \n', LowReward)
else
    set(hObject,'String',num2str(handles.defaultLowRreward))
    error('Low reward must be scalar value')
end

end % function


% -------------------------------------------------------------------------
function edit_DeviationSign_Callback(hObject, ~)
input = get(hObject, 'String');

switch input
    case '+'
        
    case '-'
        
    otherwise
        set(hObject,'String','')
        error('Deviation sign can only be + or -')
end

fprintf('Deviation sign is : %s \n', input)

end % function


% -------------------------------------------------------------------------
function pushbutton_PLOT_ALL_GUIroutine(~, eventdata)

switch eventdata.EventName
    
    case 'Action'
        
        global S %#ok<TLEV>
        
        if isempty(S)
            warning('No stats to plot')
            return
        end
        
        ADAPT.Stats.PLOT_ALL( S )
        
    case 'ButtonDown'
        
        % Get file
        [filename, pathname] = uigetfile(fullfile('..','data','*.mat'));
        
        if isnumeric(filename)
            return
        end
        
        % Load
        L = load(fullfile(pathname,filename));
        
        % Plot loaded file
        ADAPT.Stats.PLOT_ALL( L.S )
end

end % function
