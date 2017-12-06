function UpdateCursor( Cursor, deviation )
global S prevX prevY newX newY

switch S.InputMethod
    case 'Joystick'
        [newX, newY] = ADAPT.QueryJoystickData( Cursor.screenX, Cursor.screenY );
    case 'Mouse'
        [newX, newY] = ADAPT.QueryMouseData( Cursor.wPtr, Cursor.Xorigin, Cursor.Yorigin, Cursor.screenY );
end

% If new data, then apply deviation
if ~(newX == prevX && newY == prevY)
    
    [ dXc, dYc ] = ADAPT.ApplyDeviation( prevX, prevY, newX, newY, deviation );
    
    Cursor.Move(Cursor.X + dXc, Cursor.Y + dYc)
    
    prevX = newX;
    prevY = newY;
    
end

end % function
