classdef Text < baseObject
    %TEXT Class to print text in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        color
        
        content
        
        Xptb
        Yptb
        
        % Internal variables
        
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = Text( color, content, Xptb, Yptb )
            % obj = Text( color, content, Xptb, Yptb )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                self.color   = color;
                self.content = content;
                self.Xptb    = Xptb;
                self.Yptb    = Yptb;
                
                % ================== Callback =============================
                
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
