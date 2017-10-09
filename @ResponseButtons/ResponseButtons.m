classdef ResponseButtons < baseObject
    % RESPONSEBUTTONS Class to prepare and draw a fixation cross in PTB
    
    % Screen('FillOval', windowPtr [,color] [,rect] [,perfectUpToMaxDiameter]);
    
    %% Properties
    
    properties
        
        % Parameters
        
        height    = zeros(0)   % size of button base, in pixels
        side      = ''         % 'Left' or 'Right' buttons
        center    = zeros(0,2) % [ CenterX CenterY ], in pixels
        
        % Internal variables
        
        width     = zeros(0)   % width of each arms, in pixels
        
        baseRect  = zeros(1,4) % rectangle for the base of buttons, in pixels (grey part, support)
        baseColor = zeros(1,3) % [R G B] from 0 to 255
        ovalRect  = zeros(4,4) % rectangle for the 4 buttons, in pixels
        ovalColor = zeros(3,4) % [R G B] from 0 to 255
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = ResponseButtons( height ,  side , center )
            % obj = ResponseButtons( height=ScreenHeight*0.6 (pixels) , side='Left' , center = [ CenterX CenterY ] (pixels) )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- dim ----
                assert( isscalar(height) && isnumeric(height) && height>0 && height==round(height) , ...
                    'height = size of button base, in pixels' )
                
                
                % --- side ----
                assert( ischar(side) && any(strcmpi(side,{'right','r','left','l'})) , ...
                    'side =  ''Left'' or ''Right'' buttons' )
                               
                % --- center ----
                assert( isvector(center) && isnumeric(center) && all( center>0 ) && all(center == round(center)) , ...
                    'center = [ CenterX CenterY ] of the cross, in pixels' )
                
                obj.height    = height;
                obj.side   = side;
                obj.center = center;
                
                % ================== Callback =============================
                
                obj.GenerateObject
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
