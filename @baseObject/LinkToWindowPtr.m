function LinkToWindowPtr( obj, wPtr )

try
    Screen('GetWindowInfo',wPtr); % assert window exists and it's pointer is correct
    obj.wPtr = wPtr;
catch err
    rethrow(err)
end

end % function
