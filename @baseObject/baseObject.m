classdef baseObject < handle
    % BASEOBJECT is a 'virtual' class : all subclasses contain this virtual class methods and attributes
    
    properties
        
        wPtr = '' % Pointer to the PTB screen window
        
    end
    
    methods
        
        % --- Constructor -------------------------------------------------
        % no constructor : this is a 'virtual' object
        % -----------------------------------------------------------------
        
    end
    
end % classdef
