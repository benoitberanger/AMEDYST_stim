function outside = IsOutside( Cursor, Target )

distance = sqrt( (Cursor.Xptb-Target.Xptb)^2 + (Cursor.Yptb-Target.Yptb)^2 );

if distance < (Target.diameter + Cursor.diameter)/2
    outside = 1;
else
    outside = 0;
end

end % function
