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
                    
                    trialRunning = 1;
                    
                    % ~~~ Step 1 : Draw target  ~~~
                    
                    BigCircle.Draw
                    Cross.Draw
                    
                    Target.diskCurrentColor = Target.diskBaseColor;
                    Target.Move( TargetBigCirclePosition, Parameters.ParadigmeAngle(TrialIndex,3) )
                    Target.Draw
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    trialStartOnset = Screen('Flip',S.PTB.wPtr);
                    
                    % ~~~ Step 2 : Draw target  ~~~
                    
                    while trialRunning
                        
                        BigCircle.Draw
                        Cross.Draw
                        Target.Draw
                        ADAPT.UpdateCursor(Cursor, EP, evt)
                        
                        Screen('DrawingFinished',S.PTB.wPtr);
                        Screen('Flip',S.PTB.wPtr);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Fetch keys
                        [keyIsDown, secs, keyCode] = KbCheck;
                        if keyIsDown
                            % ~~~ ESCAPE key ? ~~~
                            [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                            if EXIT
                                break
                            end
                        end
                        % Time's up ?
                        if secs > trialStartOnset + Parameters.TrialMaxDuration
                            trialRunning = 0;
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                    end % while : Setp 2
                    
                    
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
