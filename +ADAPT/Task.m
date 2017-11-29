function [ TaskData ] = Task
global S

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
    
    % Initialize some varibles
    EXIT = 0;
    
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
                
            case {'Direct', 'Deviation'} % ------------------------------------------------
                
                while 1
                    
                    BigCircle.Draw
                    
                    Target.Move((BigCircle.diameter-BigCircle.thickness)/2,0)
                    Target.Draw
                    
                    %                     for angle = 15:15:360
                    %                         Target.Move([],angle)
                    %                         Target.Draw
                    %                     end
                    
                    Target.Move(0,0)
                    Target.Draw
                    
                    Cross.Draw
                    
                    switch S.InputMethod
                        case 'Joystick'
                            [newX, newY] = ADAPT.QueryJoystickData( Cursor.screenX, Cursor.screenY );
                        case 'Mouse'
                            [newX, newY] = ADAPT.QueryMouseData( Cursor.wPtr, Cursor.Xorigin, Cursor.Yorigin, Cursor.screenY );
                    end
                    
                    % If new data, then apply deviation
                    if ~(newX == prevX && newY == prevY)
                        
                        switch EP.Data{evt,1}
                            case 'Direct'
                                deviation = 0;
                            case 'Deviation'
                                deviation = EP.Data{evt,5};
                        end
                        
                        [ dXc, dYc ] = ADAPT.ApplyDeviation( prevX, prevY, newX, newY, deviation );
                        
                        Cursor.Move(Cursor.X + dXc, Cursor.Y + dYc)
                        
                        prevX = newX;
                        prevY = newY;
                        
                    end
                    
                    Cursor.Draw
                    
                    Screen('Flip',S.PTB.wPtr);
                    
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    
                    if keyIsDown
                        
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                        
                    end
                    
                end
                
                
                
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
