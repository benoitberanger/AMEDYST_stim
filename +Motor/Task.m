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
    
    [ Buttons    ] = Common.PrepareResponseButtons;
    
    
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
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Rest' % -------------------------------------------------
                
                
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
                if ~strcmp(EP.Data{evt-1,1},'StartTime')
                    KL.GetQueue;
                    results = Common.SequenceAnalyzer(EP.Data{evt-1,4}, S.Side, EP.Data{evt-1,3}, from, KL.EventCount, KL);
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
                
                
            case {'Simple', 'Complex'}
                
                % Parameters for this block
                sequence_str = EP.Data{evt,4};                                            % sequence of the block
                limitValue   = StartTime + EP.Data{evt,2} + EP.Data{evt,3} - S.PTB.slack; % when to stop the block
                
                % Initilization
                next_input = str2double(sequence_str(1));
                condition = secs < limitValue;
                
                % Draw the first button to tap, save onst
                Buttons.Draw(next_input);
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
                            
                            Buttons.Draw(next_input);
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
