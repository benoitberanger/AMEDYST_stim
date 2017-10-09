function Catch( err )
% Catch wrapper

sca;
Priority( 0 );
ShowCursor;
rethrow(err);

end % function
