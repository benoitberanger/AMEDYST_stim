function GenerateCoords( obj )

xCoords = [-obj.dim obj.dim 0 0]/2;
yCoords = [0 0 -obj.dim obj.dim]/2;

obj.allCoords = [xCoords; yCoords];

end
