function [ TaskData ] = Task
global S

try
    %% Tunning of the task
    
    [ EP ] = SEQ.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Prepare objects
    
    [ WhiteCross ] = SEQ.PrepareFixationCross;
    crossBaseColor = WhiteCross.color;
    
    switch S.Feedback
        case 'On'
            [ Buttons ] = SEQ.PrepareResponseButtons;
        case 'Off'
    end
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink
    
    
    %% Go
    
    % Initialize some varibles
    EXIT = 0;
    from = 1;
    
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
                [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                
                
            case 'Instruction'
                
                DrawFormattedText(S.PTB.wPtr, EP.Data{evt+1,1}, 'center', 'center', S.Parameters.Text.Color);
                instructionOnset = Screen('Flip',S.PTB.wPtr,StartTime + EP.Data{evt,2} - S.PTB.slack);
                Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                ER.AddEvent({EP.Data{evt,1} instructionOnset-StartTime [] []})
                
                
            case {'Simple', 'Complexe'}
                
                N = round(EP.Data{evt,3}/S.PTB.IFI);
                
                amplitude = (crossBaseColor-S.Parameters.Video.ScreenBackgroundColor)/2;
                offcet    = (crossBaseColor+S.Parameters.Video.ScreenBackgroundColor)/2 ;
                frequency = EP.Data{evt,5}*S.PTB.IFI;
                phase     =  -pi/2 ;
                
                colorScale = @(frame_counter) amplitude*square( 2*pi*frequency*frame_counter + phase ) + offcet;
                
                % Wait for the beguining of the block 
                WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.slack);
                
                
                for n = 0 : N-1
                    WhiteCross.color =  colorScale(n);
                    
                    WhiteCross.Draw;
                    onset = Screen('Flip',S.PTB.wPtr);
                    
                    % Block onset
                    if n == 0
                        Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                        ER.AddEvent({EP.Data{evt,1} onset-StartTime [] []})
                    end
                    
                end
                
                %                 % Parameters for this block
                %                 sequence_str = EP.Data{evt,4};                                            % sequence of the block
                %                 limitValue   = StartTime + EP.Data{evt,2} + EP.Data{evt,3} - S.PTB.slack; % when to stop the block
                %
                %                 % Initilization
                %                 next_input = str2double(sequence_str(1));
                %                 condition = secs < limitValue;
                %
                %                 % Draw the first button to tap, save onset
                %                 switch S.Feedback
                %                     case 'On'
                %                         Buttons.Draw(next_input);
                %                     case 'Off'
                %                         WhiteCross.Draw;
                %                 end
                %                 blockOnset = Screen('Flip',S.PTB.wPtr,StartTime + EP.Data{evt,2} - S.PTB.slack);
                %                 Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                %                 ER.AddEvent({EP.Data{evt,1} blockOnset-StartTime [] []})
                %
                %                 lastOnset = blockOnset;
                %
                %                 while condition
                %
                %                     % Fetch keys
                %                     [keyIsDown, secs, keyCode] = KbCheck;
                %
                %                     % Check condition
                %                     condition = secs < limitValue;
                %
                %                     if secs >= lastOnset + EP.Data{evt,4}
                %
                %                         % Prepare next input
                %                         sequence_str = circshift(sequence_str,[0 -1]);
                %                         next_input = str2double(sequence_str(1));
                %
                %                         switch S.Feedback
                %                             case 'On'
                %                                 Buttons.Draw(next_input);
                %                                 Screen('Flip',S.PTB.wPtr);
                %                             case 'Off'
                %                         end
                %                     end
                %
                %                 end
                %
                %                 if keyIsDown
                %
                %                     if keyCode(Side(next_input))
                %                         Common.SendParPortMessage(sprintf('finger_%d',next_input)); % Parallel port
                %                     end
                %
                %                     % ~~~ ESCAPE key ? ~~~
                %                     [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                %                     if EXIT
                %                         break
                %                     end
                %
                %                 end % while
                
                
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
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
