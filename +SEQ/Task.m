function [ TaskData ] = Task
global S

try
    %% Tunning of the task
    
    [ EP ] = SEQ.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL, SR ] = Common.PrepareRecorders( EP );
    
    
    %% Prepare objects
    
    [ Cross ] = SEQ.PrepareFixationCross;
    
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
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                Cross.Draw;
                Screen('Flip',S.PTB.wPtr);
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Repos' % ------------------------------------------------
                
                % ~~~ Analyse the last key inputs ~~~
                if ~strcmp(EP.Data{evt-2,1},'StartTime') % it means S.Feedback==Off
                    KL.GetQueue;
                    results = Common.SequenceAnalyzer(EP.Data{evt-2,4}, S.Side, EP.Data{evt-2,3}, from, KL.EventCount, KL);
                    from = KL.EventCount;
                    ER.Data{evt-1,4} = results;
                    disp(results)
                end
                
                % Prepare color variations
                switch S.Feedback
                    case 'On'
                        
                        % Prepare inputs
                        sequence_str = EP.Data{evt,4}; % sequence of the block
                        next_input = str2double(sequence_str(1));
                        
                        maxColor  = Buttons.darkOvals*2;
                        minColor  = Buttons.darkOvals  ;
                        
                    case 'Off'
                        
                        maxColor  = Cross.baseColor;
                        minColor  = S.Parameters.Video.ScreenBackgroundColor;
                        
                end
                
                % Color morphing
                amplitude = (maxColor-minColor)/2;
                offcet    = (maxColor+minColor)/2 ;
                frequency = EP.Data{evt,5};
                phase     =  -pi/2 ;
                
                colorScale = @(frame_counter) amplitude*square( 2*pi*frequency*(frame_counter*S.PTB.IFI) + phase ) + offcet;
                
                % How many images in this block ?
                Nframes       = round(EP.Data{evt,3}/S.PTB.IFI);
                FramesInCycle = round(1/frequency   /S.PTB.IFI);
                
                % Wait for the begining of the block
                onset = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.slack/2);
                
                % Display
                for frame = 0 : Nframes-1
                    
                    % colorScale(n) % <= for diagnostic
                    
                    switch S.Feedback
                        case 'On'
                            
                            Buttons.ovalCurrentColor = colorScale(frame);
                            Buttons.Draw(next_input);
                            
                            % Change input button at the end each flickering cycle
                            if frame>0 && mod(frame,FramesInCycle)== 0
                                % Fetch next input
                                sequence_str = circshift(sequence_str,[0 -1]);
                                next_input = str2double(sequence_str(1));
                            end
                            
                        case 'Off'
                            
                            Cross.currentColor = colorScale(frame);
                            Cross.Draw;
                            
                    end
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    Screen('Flip'           ,S.PTB.wPtr);
                    
                    % Block onset
                    if frame == 0
                        Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                        ER.AddEvent({EP.Data{evt,1} onset-StartTime [] []})
                    end
                    
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    
                    if keyIsDown
                        
                        % Key press ?
                        if any(keyCode(Side))
                            key_input = find(keyCode(Side),1);
                            Common.SendParPortMessage(sprintf('finger_%d',key_input)); % Parallel port
                        end
                        
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                        
                    end
                    
                end % for Nframes
                
                
            case 'Instruction'
                
                DrawFormattedText(S.PTB.wPtr, EP.Data{evt+1,1}, 'center', 'center', S.Parameters.Text.Color);
                instructionOnset = Screen('Flip',S.PTB.wPtr,StartTime + EP.Data{evt,2} - S.PTB.slack);
                Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                ER.AddEvent({EP.Data{evt,1} instructionOnset-StartTime [] []})
                
                
            case {'Simple', 'Complexe'}
                
                % Prepare color variations
                switch S.Feedback
                    case 'On'
                        
                        % Prepare inputs
                        sequence_str = EP.Data{evt,4}; % sequence of the block
                        next_input = str2double(sequence_str(1));
                        
                        maxColor  = Buttons.ovalBaseColor;
                        minColor  = Buttons.darkOvals;
                        
                    case 'Off'
                        
                        maxColor  = Cross.baseColor;
                        minColor  = S.Parameters.Video.ScreenBackgroundColor;
                        
                end
                
                % Color morphing
                amplitude = (maxColor-minColor)/2;
                offcet    = (maxColor+minColor)/2 ;
                frequency = EP.Data{evt,5};
                phase     =  -pi/2 ;
                
                colorScale = @(frame_counter) amplitude*square( 2*pi*frequency*(frame_counter*S.PTB.IFI) + phase ) + offcet;
                
                % How many images in this block ?
                Nframes       = round(EP.Data{evt,3}/S.PTB.IFI);
                FramesInCycle = round(1/frequency   /S.PTB.IFI);
                
                % Wait for the begining of the block
                onset = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.slack/2);
                
                % Display
                for frame = 0 : Nframes-1
                    
                    % colorScale(n) % <= for diagnostic
                    
                    switch S.Feedback
                        case 'On'
                            
                            Buttons.ovalCurrentColor = colorScale(frame);
                            Buttons.Draw(next_input);
                            
                            % Change input button at the end each flickering cycle
                            if frame>0 && mod(frame,FramesInCycle)== 0
                                % Fetch next input
                                sequence_str = circshift(sequence_str,[0 -1]);
                                next_input = str2double(sequence_str(1));
                            end
                            
                        case 'Off'
                            
                            Cross.currentColor = colorScale(frame);
                            Cross.Draw;
                            
                    end
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    Screen('Flip'           ,S.PTB.wPtr);
                    
                    % Block onset
                    if frame == 0
                        Common.SendParPortMessage(EP.Data{evt,1}); % Parallel port
                        ER.AddEvent({EP.Data{evt,1} onset-StartTime [] []})
                    end
                    
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    
                    if keyIsDown
                        
                        % Key press ?
                        if any(keyCode(Side))
                            key_input = find(keyCode(Side),1);
                            Common.SendParPortMessage(sprintf('finger_%d',key_input)); % Parallel port
                        end
                        
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                        
                    end
                    
                end % for Nframes
                
            otherwise % ---------------------------------------------------
                
                error('unknown envent')
                
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if EXIT
            break
        end
        
    end % for
    
    
    %% End of stimulation
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, SR, StartTime, StopTime );
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
