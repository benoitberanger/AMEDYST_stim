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
    
    [ WhiteCross ] = Common.PrepareFixationCross  ;
    
    switch S.Feedback
        case 'On'
            [ Buttons ] = Common.PrepareResponseButtons;
        case 'Off'
    end
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink
    
    
    %% Go
    
    % Initialize some varibles
    Exit_flag = 0;
    from      = 1;
    
    switch S.Side
        case 'Left'
            Side = S.Parameters.Fingers.Left; % shortcut
        case 'Right'
            Side = S.Parameters.Fingers.Right; % shortcut
    end
    limitType = 'time';
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                WhiteCross.Draw;
                Screen('Flip',S.PTB.wPtr);
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Repos' % ------------------------------------------------
                
                
                % ~~~ Display white cross ~~~
                WhiteCross.Draw
                switch limitType
                    case 'tap'
                        crossOnset = Screen('Flip',S.PTB.wPtr);
                    case 'time'
                        crossOnset = Screen('Flip',S.PTB.wPtr,StartTime + EP.Data{evt,2} - S.PTB.slack);
                end
                Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                ER.AddEvent({EP.Data{evt,1} crossOnset-StartTime [] []})
                
                % ~~~ Analyse the last key inputs ~~~
                switch S.Feedback
                    case 'On'
                        evt_to_check = evt-1;
                    case 'Off'
                        evt_to_check = evt-2;
                end
                if ~strcmp(EP.Data{evt_to_check,1},'StartTime') % it means S.Feedback==Off
                    KL.GetQueue;
                    switch S.Feedback
                        case 'On'
                            results = Common.SequenceAnalyzer(EP.Data{evt-1,4}, S.Side, EP.Data{evt-1,3}, from, KL.EventCount, KL);
                        case 'Off'
                            results = Common.SequenceAnalyzer(EP.Data{evt-2,4}, S.Side, EP.Data{evt-2,3}, from, KL.EventCount, KL);
                    end
                    from = KL.EventCount;
                    ER.Data{evt-1,4} = results;
                    disp(results)
                end
                
                % The WHILELOOP below is a trick so we can use ESCAPE key to quit
                % earlier.
                keyCode = zeros(1,256);
                secs = crossOnset;
                PTBtimeLimit = crossOnset + EP.Data{evt,3} - S.PTB.slack;
                while ~( keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII) || ( secs > PTBtimeLimit ) )
                    [~, secs, keyCode] = KbCheck;
                end
                
                % ~~~ ESCAPE key ? ~~~
                [ Exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                
                
            case 'Instruction'
                
                DrawFormattedText(S.PTB.wPtr, EP.Data{evt+1,1}, 'center', 'center', S.Parameters.Text.Color);
                instructionOnset = Screen('Flip',S.PTB.wPtr,StartTime + EP.Data{evt,2} - S.PTB.slack);
                Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                ER.AddEvent({EP.Data{evt,1} instructionOnset-StartTime [] []})
                
                
            case {'Simple', 'Complexe'}
                
                % Parameters for this block
                sequence_str = EP.Data{evt,4};                                            % sequence of the block
                limitValue   = StartTime + EP.Data{evt,2} + EP.Data{evt,3} - S.PTB.slack; % when to stop the block
                
                % Initilization
                next_input = str2double(sequence_str(1));
                condition = secs < limitValue;
                
                % Draw the first button to tap, save onst
                switch S.Feedback
                    case 'On'
                        Buttons.Draw(next_input);
                    case 'Off'
                        WhiteCross.Draw;
                end
                blockOnset = Screen('Flip',S.PTB.wPtr,StartTime + EP.Data{evt,2} - S.PTB.slack);
                Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                ER.AddEvent({EP.Data{evt,1} blockOnset-StartTime [] []})
                
                % Counters
                tap  = 0;
                good = 0;
                bad  = 0;
                
                while condition
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    % Check condition
                    condition = secs < limitValue;
                    
                    if keyIsDown
                        
                        if keyCode(Side(next_input))
                            
                            Common.SendParPortMessage(sprintf('finger_%d',next_input)); % Parallel port
                            
                            good = good + 1;
                            sequence_str = circshift(sequence_str,[0 -1]);
                            
                            next_input = str2double(sequence_str(1));
                            
                            switch S.Feedback
                                case 'On'
                                    Buttons.Draw(next_input);
                                case 'Off'
                                    WhiteCross.Draw;
                            end
                            Screen('Flip',S.PTB.wPtr);
                            
                        else
                            good = 0; % reset the counter
                            bad  = bad + 1;
                        end
                        tap  = tap  + 1;
                        
                        % ~~~ ESCAPE key ? ~~~
                        [ Exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if Exit_flag
                            break
                        end
                        
                    end
                    
                end % while
                
                
            otherwise % ---------------------------------------------------
                
                error('unknown envent')
                
                
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
