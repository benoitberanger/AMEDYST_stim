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
    
    Cross                  = ADAPT.PrepareCross    ;
    BigCircle              = ADAPT.PrepareBigCircle;
    [ Target, PrevTarget ] = ADAPT.PrepareTarget   ;
    Cursor                 = ADAPT.PrepareCursor   ;
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink
    
    
    %% Go
    
    % Initialize some variables
    EXIT = 0;
    TrialIndex = 0;
    TargetBigCirclePosition = (BigCircle.diameter-BigCircle.thickness)/2;
    
    Green = [0 255 0];
    Red   = [255 0 0];
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
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
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                StopTime = GetSecs;
                
                % Record StopTime
                ER.AddStopTime( 'StopTime' , StopTime - StartTime );
                RR.AddStopTime( 'StopTime' , StopTime - StartTime );
                
                ShowCursor;
                Priority( 0 );
                
            case {'Direct', 'Deviation'} % --------------------------------
                
                for trialIndexInBlock = 1 : EP.Data{evt,4}
                    
                    % Counter = trial index
                    TrialIndex = TrialIndex + 1;
                    
                    
                    %% ~~~ Step 0 : Jitter between trials ~~~
                    
                    step0Running = 1;
                    counter_step0 = 0;
                    
                    while step0Running
                        
                        counter_step0 = counter_step0 + 1;
                        
                        BigCircle.Draw
                        Cross.Draw
                        ADAPT.UpdateCursor(Cursor, EP.Data{evt,5})
                        
                        Screen('DrawingFinished',S.PTB.wPtr);
                        lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                        SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                        
                        % Record trial onset
                        if counter_step0 == 1
                            ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4} EP.Data{evt,5}})
                            step0onset = lastFlipOnset;
                        end
                        
                        if lastFlipOnset >= step0onset + Parameters.ParadigmeAngle(TrialIndex,3)
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
                    
                    Target.diskCurrentColor = Target.diskBaseColor;
                    Target.Move( TargetBigCirclePosition, Parameters.ParadigmeAngle(TrialIndex,2) )
                    Target.Draw
                    
                    PrevTarget.diskCurrentColor = Red;
                    PrevTarget.Move( 0, 0 )
                    PrevTarget.Draw
                    
                    ADAPT.UpdateCursor(Cursor, EP.Data{evt,5})
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    flipOnset_step_1 = Screen('Flip',S.PTB.wPtr);
                    SR.AddSample([flipOnset_step_1-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                    
                    %% ~~~ Step 2 : User moves cursor to target @ big ring  ~~~
                    
                    startCursorInTarget = [];
                    step2Running = 1;
                    
                    draw_PrevTraget      = 1;
                    has_already_traveled = 0;
                    
                    frame_start = SR.SampleCount;
                    
                    while step2Running
                        
                        BigCircle.Draw
                        Cross.Draw
                        Target.Draw
                        if draw_PrevTraget
                            PrevTarget.Draw
                        end
                        ADAPT.UpdateCursor(Cursor, EP.Data{evt,5})
                        Cursor.Draw
                        
                        Screen('DrawingFinished',S.PTB.wPtr);
                        lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                        SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                        
                        % Is cursor center in the previous target (@ center) ?
                        if     IsInRect(Cursor.Xptb,Cursor.Yptb,PrevTarget.Rect) &&  draw_PrevTraget % yes
                        elseif IsInRect(Cursor.Xptb,Cursor.Yptb,PrevTarget.Rect) && ~draw_PrevTraget % back inside
                        elseif draw_PrevTraget % just outside
                            PrevTarget.diskCurrentColor = PrevTarget.diskBaseColor;
                            draw_PrevTraget = 0;
                            ReactionTimeOUT = lastFlipOnset - flipOnset_step_1;
                        else
                        end
                        
                        % Is cursor center in target ?
                        if IsInRect(Cursor.Xptb,Cursor.Yptb,Target.Rect) % yes
                            
                            Target.diskCurrentColor = Green;
                            
                            if isempty(startCursorInTarget) % Cursor has just reached the target
                                
                                startCursorInTarget = lastFlipOnset;
                                
                                if ~has_already_traveled
                                    TravelTimeOUT = lastFlipOnset - flipOnset_step_1;
                                    has_already_traveled = 1;
                                end
                                
                            elseif lastFlipOnset >= startCursorInTarget + Parameters.TimeSpentOnTargetToValidate % Cursor remained in the target long enough
                                step2Running = 0;
                            end
                            
                        else % no, then reset
                            startCursorInTarget = []; % reset
                            Target.diskCurrentColor = Target.diskBaseColor;
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
                    
                    Target.diskCurrentColor = Target.diskBaseColor;
                    frame_stop = SR.SampleCount;
                    
                    if EXIT
                        break
                    else
                        OutRecorder.AddEvent({TrialIndex Parameters.ParadigmeAngle(TrialIndex,3) EP.Data{evt,5} Parameters.ParadigmeAngle(TrialIndex,2) frame_start frame_stop ReactionTimeOUT TravelTimeOUT})
                    end
                    
                    
                    %% ~~~ Step 3 : Draw target @ center ~~~
                    
                    BigCircle.Draw
                    Cross.Draw
                    
                    Target.diskCurrentColor = Target.diskBaseColor;
                    Target.Move(0,0)
                    Target.Draw
                    
                    PrevTarget.diskCurrentColor = Red;
                    PrevTarget.Move( TargetBigCirclePosition, Parameters.ParadigmeAngle(TrialIndex,2) )
                    PrevTarget.Draw
                    
                    ADAPT.UpdateCursor(Cursor, EP.Data{evt,5})
                    Cursor.Draw
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    flipOnset_step_3 = Screen('Flip',S.PTB.wPtr);
                    SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                    
                    %% ~~~ Step 4 : User moves cursor to target @ center ~~~
                    
                    startCursorInTarget = [];
                    step4Running = 1;
                    
                    draw_PrevTraget      = 1;
                    has_already_traveled = 0;
                    
                    frame_start = SR.SampleCount;
                    
                    while step4Running
                        
                        BigCircle.Draw
                        Cross.Draw
                        Target.Draw
                        if draw_PrevTraget
                            PrevTarget.Draw
                        end
                        ADAPT.UpdateCursor(Cursor, EP.Data{evt,5})
                        Cursor.Draw
                        
                        Screen('DrawingFinished',S.PTB.wPtr);
                        lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                        SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                        
                        % Is cursor center in the previous target (@ ring) ?
                        if     IsInRect(Cursor.Xptb,Cursor.Yptb,PrevTarget.Rect) &&  draw_PrevTraget % yes
                        elseif IsInRect(Cursor.Xptb,Cursor.Yptb,PrevTarget.Rect) && ~draw_PrevTraget % back inside
                        elseif draw_PrevTraget % just outside
                            PrevTarget.diskCurrentColor = PrevTarget.diskBaseColor;
                            draw_PrevTraget = 0;
                            ReactionTimeIN = lastFlipOnset - flipOnset_step_3;
                        else
                        end
                        
                        % Is cursor center in target ?
                        if IsInRect(Cursor.Xptb,Cursor.Yptb,Target.Rect) % yes
                            
                            Target.diskCurrentColor = Green;
                            
                            if isempty(startCursorInTarget) % Cursor has just reached the target
                                
                                startCursorInTarget = lastFlipOnset;
                                
                                if ~has_already_traveled
                                    TravelTimeIN = lastFlipOnset - flipOnset_step_3;
                                    has_already_traveled = 1;
                                end
                                
                            elseif lastFlipOnset >= startCursorInTarget + Parameters.TimeSpentOnTargetToValidate % Cursor remained in the target long enough
                                step4Running = 0;
                            end
                            
                        else % no, then reset
                            startCursorInTarget = []; % reset
                            Target.diskCurrentColor = Target.diskBaseColor;
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
                    
                    Target.diskCurrentColor = Target.diskBaseColor;
                    frame_stop = SR.SampleCount;
                    
                    if EXIT
                        break
                    else
                        InRecorder.AddEvent({TrialIndex Parameters.ParadigmeAngle(TrialIndex,3) EP.Data{evt,5} Parameters.ParadigmeAngle(TrialIndex,2) frame_start frame_stop ReactionTimeIN TravelTimeIN})
                    end
                    
                    
                end % for : trial in block
                
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
    ADAPT.UpdateCursor(Cursor, EP.Data{evt,5})
    Screen('DrawingFinished',S.PTB.wPtr);
    lastFlipOnset = Screen('Flip',S.PTB.wPtr);
    SR.AddSample([lastFlipOnset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
    
    
    %% End of stimulation
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, SR, StartTime, StopTime );
    TaskData.Parameters = Parameters;
    
    OutRecorder.ClearEmptyEvents;
    InRecorder. ClearEmptyEvents;
    TaskData.OutRecorder = OutRecorder;
    TaskData.InRecorder  = InRecorder;
    assignin('base','OutRecorder', OutRecorder)
    assignin('base','InRecorder' , InRecorder )
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
