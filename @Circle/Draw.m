function Draw( obj )

obj.AssertReady

if obj.filled
    obj.DrawDisk
end

if obj.valued
    obj.DrawValue
end

obj.DrawFrame

end % function
