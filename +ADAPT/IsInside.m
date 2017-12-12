function inside = IsInside( Cursor, Target )

distance = sqrt( (Cursor.Xptb-Target.Xptb)^2 + (Cursor.Yptb-Target.Yptb)^2 );

if distance < (Target.diameter - Cursor.diameter)/2
    inside = 1;
else
    inside = 0;
end

end % function
