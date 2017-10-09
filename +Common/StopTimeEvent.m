function [ ER, RR, StopTime ] = StopTimeEvent( EP, ER, RR, StartTime, evt )

% Fixation duration handeling

StopTime = WaitSecs('UntilTime', StartTime + ER.Data{ER.EventCount,2} + EP.Data{evt-1,3} );

% Record StopTime
ER.AddStopTime( 'StopTime' , StopTime - StartTime );
RR.AddStopTime( 'StopTime' , StopTime - StartTime );

ShowCursor;
Priority( 0 );

end % function
