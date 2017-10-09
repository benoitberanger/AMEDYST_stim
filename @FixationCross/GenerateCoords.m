function GenerateCoords( obj )

xCoords = [-obj.dim obj.dim 0 0];
yCoords = [0 0 -obj.dim obj.dim];

obj.allCoords = [xCoords; yCoords];

end
