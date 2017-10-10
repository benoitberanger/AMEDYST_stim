function [ TaskData ] = Task
global S

try
    %% Tunning of the task
    
    [ EP ] = Motor.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Prepare objects
    
    %     [ audioObj ] = Common.Audio.PrepareAudioFiles;
    
    [ WhiteCross ] = Common.PrepareFixationCross;
    
    [ Buttons ] = Common.PrepareResponseButtons;
    
    
    
    
    
    
    
    %%
    
    Exit_flag = 0;
    while ~Exit_flag
        
        [keyIsDown, secs, keyCode] = KbCheck;
        
        f = [];
        if keyIsDown
           if keyCode(S.Parameters.Fingers.Left(2))
               f = 2;
               elseif keyCode(S.Parameters.Fingers.Left(3))
               f = 3;
               elseif keyCode(S.Parameters.Fingers.Left(4))
               f = 4;
               elseif keyCode(S.Parameters.Fingers.Left(5))
               f = 5;
           end
        end
        
%         Buttons.Draw(f)
        WhiteCross.Draw
        Screen('Flip',S.PTB.wPtr);
        
        
        [ Exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, 0 );
        
    end
    
    return
    
    %% Go
    
    % Initialize some varibles
    Exit_flag = 0;
    from      = 1;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Rest' % -------------------------------------------------
                
                %                 % Wrapper for the control condition. It's a script itself,
                %                 % used across several tasks
                %                 [ ER, from, Exit_flag, StopTime ] = Common.ControlCondition( EP, ER, RR, KL, StartTime, from, audioObj, evt, 'tap' );
                
            otherwise % ---------------------------------------------------
                
                %                 vbl = WaitSecs('UntilTime',StartTime + ER.Data{evt-1,2} + EP.Data{evt-1,3} - S.PTB.anticipation);
                %
                %                 ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] [] []})
                %
                %                 [ Exit_flag, StopTime ] = Common.DisplayInputsInCommandWindow( EP, ER, RR, evt, StartTime, audioObj, 'tap', Inf );
                %                 if Exit_flag
                %                     break
                %                 end
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if Exit_flag
            break
        end
        
    end % for
    
    
    %% End of stimulation
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
