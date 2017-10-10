function [ SequenceHighLow ] = Randomize01( nr0, nr1 )

iter = 0;
maxiter = 10000;

while iter < maxiter
    
    iter = iter + 1;
    
    SequenceHighLow = Shuffle([zeros(1,nr0) ones(1,nr1)]);
    SequenceHighLow_str = regexprep(num2str(SequenceHighLow),' ','');
    
    % maximum 3x(0) or 3x(1) in a row, max 2x(01) or 2x(10) in a row
    if ~(any(regexp(SequenceHighLow_str,'000')) || any(regexp(SequenceHighLow_str,'111')) || any(regexp(SequenceHighLow_str,'0101')) || any(regexp(SequenceHighLow_str,'1010')))
        break
    end
    
end

if iter >= maxiter
    error('randomizer problem : maxiter reached')
end


end % function
