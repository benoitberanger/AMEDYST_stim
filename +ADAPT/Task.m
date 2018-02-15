function [ TaskData ] = Task
global S prevX prevY newX newY

try
    %% Tunning of the task
    
    [ EP, Parameters ] = ADAPT.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL, SR, OutRecorder, InRecorder ] = Common.PrepareRecorders( EP );
    
    
    %% Prepare objects
    
    Cross                  = ADAPT.Prepare.Cross    ;
    BigCircle              = ADAPT.Prepare.BigCircle;
    [ Target, PrevTarget ] = ADAPT.Prepare.Target   ;
    Cursor                 = ADAPT.Prepare.Cursor   ;
    Reward                 = ADAPT.Prepare.Reward   ;
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink
    
    
    %% Go
    
    % Initialize some variables
    EXIT = 0;
    TargetBigCirclePosition = (BigCircle.diameter-BigCircle.thickness)/2;
    
    Red   = [255 0   0  ];
    Green = [0   255 0  ];
    Blue  = [0   128 255];
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        % Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                % Fetch initialization data
                switch S.InputMethod
                    case 'Joystick'
                        [newX, newY] = ADAPT.QueryJoystickData( Cursor.screenX, Cursor.screenY );
                    case 'Mouse'
                        SetMouse(Cursor.Xptb,Cursor.Yptb,Cursor.wPtr);
                        [newX, newY] = ADAPT.QueryMouseData( Cursor.wPtr, Cursor.Xorigin, Cursor.Yorigin, Cursor.screenY );
                end
                
                % Here at initialization, we don't apply deviation, just fetche raw data
                Cursor.Move(newX,newY);
                
                prevX = newX;
                prevY = newY;
                
                Target.valueCurrentColor = Blue;
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                StopTime = GetSecs;
                
                % Record StopTime
                ER.AddStopTime( 'StopTime' , StopTime - StartTime );
                RR.AddStopTime( 'StopTime' , StopTime - StartTime );
                
                ShowCursor;
                Priority( 0 );
                
            case {'Direct_Pre', 'Deviation', 'Direct_Post'} % --------------------------------
                
                % Echo in the command window
                fprintf('#%3d deviation=%3d° target=%3d° value=%3d%% reward=%d \n', round( cell2mat(EP.Data(evt,[5 6 7 9 10])) ) )
                
                
                %% ~~~ Step 0 : Jitter between trials ~~~
                
                step0Running  = 1;
                counter_step0 = 0;
                
                while step0Running
                    
                    counter_step0 = counter_step0 + 1;
                    
                    BigCircle.Draw
                    Cross.Draw
                    ADAPT.UpdateCursor(Cursor, EP.Get(evt,'Deviation'))
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                    SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                    % Record trial onset & step onset
                    if counter_step0 == 1
                        ER.AddEvent({EP.Data{evt,1}              lastFlipOnset-StartTime [] EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,6} EP.Data{evt,7} EP.Data{evt,8} EP.Data{evt,9} EP.Data{evt,10} })
                        RR.AddEvent({['Jitter__' EP.Data{evt,1}] lastFlipOnset-StartTime [] EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,6} EP.Data{evt,7} EP.Data{evt,8} EP.Data{evt,9} EP.Data{evt,10} })
                        step0onset = lastFlipOnset;
                    end
                    
                    if lastFlipOnset >= step0onset + EP.Data{evt,8}
                        step0Running = 0;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                end % while : step 0
                
                if EXIT
                    break
                end
                
                
                %% ~~~ Step 1 : Draw target @ big ring ~~~
                
                BigCircle.Draw
                Cross.Draw
                
                Target.frameCurrentColor = Target.frameBaseColor;
                Target.Move( TargetBigCirclePosition, EP.Get(evt,'Target') )
                Target.value = EP.Get(evt,'Probability');
                Target.Draw
                
                PrevTarget.frameCurrentColor = Red;
                PrevTarget.Move( 0, 0 )
                PrevTarget.Draw
                
                ADAPT.UpdateCursor(Cursor, EP.Get(evt,'Deviation'))
                
                Screen('DrawingFinished',S.PTB.wPtr);
                flipOnset_step_1 = Screen('Flip',S.PTB.wPtr);
                SR.AddSample([flipOnset_step_1-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                RR.AddEvent({['Draw@Ring__' EP.Data{evt,1}] flipOnset_step_1-StartTime [] EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,6} EP.Data{evt,7} EP.Data{evt,8} EP.Data{evt,9} EP.Data{evt,10} })
                
                
                %% ~~~ Step 2 : User moves cursor to target @ big ring  ~~~
                
                startCursorInTarget = [];
                step2Running        = 1;
                
                draw_PrevTraget      = 1;
                has_already_traveled = 0;
                
                frame_start = SR.SampleCount;
                
                counter_step1 = 0;
                
                while step2Running
                    
                    counter_step1 = counter_step1 + 1;
                    
                    BigCircle.Draw
                    Cross.Draw
                    Target.Draw
                    if draw_PrevTraget
                        PrevTarget.Draw
                    end
                    ADAPT.UpdateCursor(Cursor, EP.Get(evt,'Deviation'))
                    Cursor.Draw
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                    SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                    % Record step onset
                    if counter_step1 == 1
                        RR.AddEvent({['Move@Ring__' EP.Data{evt,1}] lastFlipOnset-StartTime [] EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,6} EP.Data{evt,7} EP.Data{evt,8} EP.Data{evt,9} EP.Data{evt,10} })
                    end
                    
                    % Is cursor center in the previous target (@ center) ?
                    if     ADAPT.IsOutside(Cursor,PrevTarget) &&  draw_PrevTraget % yes
                    elseif ADAPT.IsOutside(Cursor,PrevTarget) && ~draw_PrevTraget % back inside
                    elseif draw_PrevTraget % just outside
                        PrevTarget.frameCurrentColor = PrevTarget.frameBaseColor;
                        draw_PrevTraget = 0;
                        ReactionTimeOUT = lastFlipOnset - flipOnset_step_1;
                    else
                    end
                    
                    % Is cursor center in target ?
                    if ADAPT.IsInside(Cursor,Target) % yes
                        
                        Target.frameCurrentColor = Green;
                        
                        if isempty(startCursorInTarget) % Cursor has just reached the target
                            
                            startCursorInTarget = lastFlipOnset;
                            
                            if ~has_already_traveled
                                TravelTimeOUT = lastFlipOnset - flipOnset_step_1 - ReactionTimeOUT;
                                has_already_traveled = 1;
                            end
                            
                        elseif lastFlipOnset >= startCursorInTarget + Parameters.TimeSpentOnTargetToValidate % Cursor remained in the target long enough
                            step2Running = 0;
                        end
                        
                    else % no, then reset
                        startCursorInTarget = []; % reset
                        Target.frameCurrentColor = Target.frameBaseColor;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                end % while : Setp 2
                
                Target.frameCurrentColor = Target.frameBaseColor;
                frame_stop = SR.SampleCount;
                
                if EXIT
                    break
                else
                    OutRecorder.AddSample([EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,8} EP.Data{evt,6} EP.Data{evt,9} EP.Data{evt,7} frame_start frame_stop round(ReactionTimeOUT*1000) round(TravelTimeOUT*1000)])
                end
                
                
                %% ~~~ Step 3 : Draw target @ center ~~~
                
                BigCircle.Draw
                Cross.Draw
                
                Target.frameCurrentColor = Target.frameBaseColor;
                Target.Move(0,0)
                Target.value = 0;
                Target.Draw
                
                PrevTarget.frameCurrentColor = Red;
                PrevTarget.Move( TargetBigCirclePosition, EP.Get(evt,'Target')  )
                
                ADAPT.UpdateCursor(Cursor, EP.Get(evt,'Deviation'))
                Cursor.Draw
                
                Screen('DrawingFinished',S.PTB.wPtr);
                flipOnset_step_3 = Screen('Flip',S.PTB.wPtr);
                SR.AddSample([flipOnset_step_3-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                RR.AddEvent({['Draw@Center__' EP.Data{evt,1}] flipOnset_step_3-StartTime [] EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,6} EP.Data{evt,7} EP.Data{evt,8} EP.Data{evt,9} EP.Data{evt,10} })
                
                
                %% ~~~ Step 4 : User moves cursor to target @ center ~~~
                
                startCursorInTarget = [];
                step4Running        = 1;
                
                draw_PrevTraget      = 1;
                has_already_traveled = 0;
                
                frame_start = SR.SampleCount;
                
                counter_step4 = 0;
                
                while step4Running
                    
                    counter_step4 = counter_step4 + 1;
                    
                    BigCircle.Draw
                    Cross.Draw
                    Target.Draw
                    ADAPT.UpdateCursor(Cursor, EP.Get(evt,'Deviation'))
                    Cursor.Draw
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                    SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                    % Record step onset
                    if counter_step4 == 1
                        RR.AddEvent({['Move@Center__' EP.Data{evt,1}] lastFlipOnset-StartTime [] EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,6} EP.Data{evt,7} EP.Data{evt,8} EP.Data{evt,9} EP.Data{evt,10} })
                    end
                    
                    % Is cursor center in the previous target (@ ring) ?
                    if     ADAPT.IsOutside(Cursor,PrevTarget) &&  draw_PrevTraget % yes
                    elseif ADAPT.IsOutside(Cursor,PrevTarget) && ~draw_PrevTraget % back inside
                    elseif draw_PrevTraget % just outside
                        PrevTarget.frameCurrentColor = PrevTarget.frameBaseColor;
                        draw_PrevTraget = 0;
                        ReactionTimeIN = lastFlipOnset - flipOnset_step_3;
                    else
                    end
                    
                    % Is cursor center in target ?
                    if ADAPT.IsInside(Cursor,Target) % yes
                        
                        Target.frameCurrentColor = Green;
                        
                        if isempty(startCursorInTarget) % Cursor has just reached the target
                            
                            startCursorInTarget = lastFlipOnset;
                            
                            if ~has_already_traveled
                                TravelTimeIN = lastFlipOnset - flipOnset_step_3 - ReactionTimeIN;
                                has_already_traveled = 1;
                            end
                            
                        elseif lastFlipOnset >= startCursorInTarget + Parameters.TimeSpentOnTargetToValidate % Cursor remained in the target long enough
                            step4Running = 0;
                        end
                        
                    else % no, then reset
                        startCursorInTarget = []; % reset
                        Target.frameCurrentColor = Target.frameBaseColor;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                end % while : Setp 4
                
                Target.frameCurrentColor = Target.frameBaseColor;
                frame_stop = SR.SampleCount;
                
                if EXIT
                    break
                else
                    InRecorder.AddSample([EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,8} EP.Data{evt,6} EP.Data{evt,9} EP.Data{evt,7} frame_start frame_stop round(ReactionTimeIN*1000) round(TravelTimeIN*1000)])
                end
                
                
                %% ~~~ Step 5 : Pause before dislpay of the reward ~~~
                
                step5Running  = 1;
                counter_step5 = 0;
                
                while step5Running
                    
                    counter_step5 = counter_step5 + 1;
                    
                    BigCircle.Draw
                    Cross.Draw
                    ADAPT.UpdateCursor(Cursor, EP.Get(evt,'Deviation'))
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                    SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                    % Record trial onset & step onset
                    if counter_step5 == 1
                        RR.AddEvent({['preReward__' EP.Data{evt,1}] lastFlipOnset-StartTime [] EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,6} EP.Data{evt,7} EP.Data{evt,8} EP.Data{evt,9} EP.Data{evt,10} })
                        step5onset = lastFlipOnset;
                    end
                    
                    if lastFlipOnset >= step5onset +Parameters.RewardDisplayTime
                        step5Running = 0;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                end % while : step 5
                
                
                %% ~~~ Step 6 : Show reward ~~~
                
                step6Running  = 1;
                counter_step6 = 0;
                
                while step6Running
                    
                    counter_step6 = counter_step6 + 1;
                    
                    BigCircle.Draw
                    Reward.Draw(EP.Get(evt,'rewarded') );
                    ADAPT.UpdateCursor(Cursor, EP.Get(evt,'Deviation'))
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                    SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                    % Record trial onset & step onset
                    if counter_step6 == 1
                        RR.AddEvent({['Reward__' EP.Data{evt,1}] lastFlipOnset-StartTime [] EP.Data{evt,4} EP.Data{evt,5} EP.Data{evt,6} EP.Data{evt,7} EP.Data{evt,8} EP.Data{evt,9} EP.Data{evt,10} })
                        step6onset = lastFlipOnset;
                    end
                    
                    if lastFlipOnset >= step6onset +Parameters.RewardDisplayTime
                        step6Running = 0;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                end % while : step 6
                
                if EXIT
                    break
                end
                
                
            otherwise % ---------------------------------------------------
                
                error('unknown envent')
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if EXIT
            break
        end
        
    end % for
    
    % "The end"
    BigCircle.Draw
    Cross.Draw
    ADAPT.UpdateCursor(Cursor, EP.Get(evt,'Deviation'))
    Screen('DrawingFinished',S.PTB.wPtr);
    lastFlipOnset = Screen('Flip',S.PTB.wPtr);
    SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
    
    
    %% End of stimulation
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, SR, StartTime, StopTime );
    TaskData.Parameters = Parameters;
    
    OutRecorder.ClearEmptySamples;
    InRecorder. ClearEmptySamples;
    TaskData.OutRecorder = OutRecorder;
    TaskData.InRecorder  = InRecorder;
    assignin('base','OutRecorder', OutRecorder)
    assignin('base','InRecorder' , InRecorder )
    
    TaskData.TargetBigCirclePosition = TargetBigCirclePosition;
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
