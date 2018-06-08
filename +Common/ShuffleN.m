function [ out ] = ShuffleN( in, N )

out = [];

for i = 1 : N
    
    out = [ out Shuffle(in) ];
    
end % for

end % function
