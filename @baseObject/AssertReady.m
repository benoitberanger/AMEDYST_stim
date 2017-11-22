function AssertReady( obj )

props = properties(obj);

for p = 1: length(props)
    
    assert( ~isempty(obj.(props{p})) , '%s is empty' , props{p} )
    
end

end % function
