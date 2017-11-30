function [ TaskData ] = Task
global S prevX prevY newX newY

try
    %% Tunning of the task
    
    [ EP, Parameters ] = ADAPT.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Prepare objects
    
    Cross     = ADAPT.PrepareCross    ;
    BigCircle = ADAPT.PrepareBigCircle;
    Target    = ADAPT.PrepareTarget   ;
    Cursor    = ADAPT.PrepareCursor   ;
    
    
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
                
                Cursor.Move(newX,newY);
                Cursor.Draw
                
                prevX = newX;
                prevY = newY;
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case {'Direct', 'Deviation'} % --------------------------------
                
                for trialIndexInBlock = 1 : EP.Data{evt,4}
                    
                    % Counter = trial index
                    TrialIndex = TrialIndex + 1;
                    
                    %% ~~~ Step 1 : Draw target @ big ring ~~~
                    
                    BigCircle.Draw
                    Cross.Draw
                    
                    Target.diskCurrentColor = Target.diskBaseColor;
                    Target.Move( TargetBigCirclePosition, Parameters.ParadigmeAngle(TrialIndex,3) )
                    Target.Draw
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    trialStartOnset = Screen('Flip',S.PTB.wPtr);
                    ER.AddEvent({EP.Data{evt,1} trialStartOnset-StartTime [] EP.Data{evt,4} EP.Data{evt,5}})
                    
                    
                    %% ~~~ Step 2 : Move cursor to target @ big ring  ~~~
                    
                    startCursorInTarget = [];
                    step2Running = 1;
                    
                    while step2Running
                        
                        BigCircle.Draw
                        Cross.Draw
                        Target.Draw
                        ADAPT.UpdateCursor(Cursor, EP, evt)
                        
                        Screen('DrawingFinished',S.PTB.wPtr);
                        lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                        
                        % Is cursor center in target ?
                        if IsInRect(Cursor.Xptb,Cursor.Yptb,Target.Rect) % yes
                            
                            Target.diskCurrentColor = Green;
                            
                            if isempty(startCursorInTarget) % Cursor has just reached the target
                                startCursorInTarget = lastFlipOnset;
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
                    
                    if EXIT
                        break
                    end
                    
                    
                    %% ~~~ Step 3 : Draw target @ center ~~~
                    
                    BigCircle.Draw
                    Cross.Draw
                    Target.Move(0,0)
                    Target.Draw
                    ADAPT.UpdateCursor(Cursor, EP, evt)
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    Screen('Flip',S.PTB.wPtr);
                    
                    
                    %% ~~~ Step 4 : Move cursor to target @ center ~~~
                    
                    startCursorInTarget = [];
                    step4Running = 1;
                    
                    while step4Running
                        
                        BigCircle.Draw
                        Cross.Draw
                        Target.Draw
                        ADAPT.UpdateCursor(Cursor, EP, evt)
                        
                        Screen('DrawingFinished',S.PTB.wPtr);
                        lastFlipOnset = Screen('Flip',S.PTB.wPtr);
                        
                        % Is cursor center in target ?
                        if IsInRect(Cursor.Xptb,Cursor.Yptb,Target.Rect) % yes
                            
                            Target.diskCurrentColor = Green;
                            
                            if isempty(startCursorInTarget) % Cursor has just reached the target
                                startCursorInTarget = lastFlipOnset;
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
                    
                    if EXIT
                        break
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
    
    
    %% End of stimulation
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    TaskData.Parameters = Parameters;
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
