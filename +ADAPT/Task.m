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
                
                StartTime = Common.StartTimeEvent;
                
                switch S.InputMethod
                    case 'Joystick'
                        [x, y] = QueryJoystickData(S.PTB.wRect(3),S.PTB.wRect(4)); % Fetch initialization data
                        Cursor.Move(x,y)                                           % Initialize cursor positon
                        prev_x = x;
                        prev_y = y;
                    case 'Mouse'
                        SetMouse(Cursor.Xptb,Cursor.Yptb,Cursor.wPtr);
                        Cursor.DrawMouse
                end
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case {'Direct', 'Deviation'} % ------------------------------------------------
                
                while 1
                    
                    BigCircle.Draw
                    
                    Target.Move((BigCircle.diameter-BigCircle.thickness)/2,0)
                    Target.Draw
                    
                    for angle = 15:15:360
                        Target.Move([],angle)
                        Target.Draw
                    end
                    
                    Target.Move(0,0)
                    Target.Draw
                    
                    Cross.Draw
                    
                    switch S.InputMethod
                        case 'Joystick'
                            
                            % Fetch joystick data
                            [x, y] = QueryJoystickData(S.PTB.wRect(3),S.PTB.wRect(4));
                            
                            % If new data, then apply deviation
                            if ~(x == prev_x && y == prev_y)
                                
                                deviation = EP.Data{evt,5};
                                
                                dX = x - prev_x;
                                dY = y - prev_y;
                                
                                dR     = sqrt(dX*dX + dY*dY); % pixels
                                dTheta = atan2(dY,dX);        % rad
                                
                                dXc = dR * cos(dTheta + deviation*pi/180); % pixels
                                dYc = dR * sin(dTheta + deviation*pi/180); % pixels
                                
                                Cursor.Move(Cursor.X + dXc, Cursor.Y + dYc)
                                
                                prev_x = x;
                                prev_y = y;
                                
                            end
                            
                            Cursor.Draw
                            
                        case 'Mouse'
                            Cursor.DrawMouse
                    end
                    
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
