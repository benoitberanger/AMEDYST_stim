classdef Circle < baseObject
    %CIRCLE Class to prepare and draw a circle==target in PTB
    
    %% Properties
    
    properties
        
        % Parameters for the creation
        
        diameter          = zeros(0)   % in pixels
        thickness         = zeros(0)   % width of each arms, in pixels
        
        frameBaseColor    = zeros(0,4) % [R G B a] from 0 to 255
        diskBaseColor     = zeros(0,4) % [R G B a] from 0 to 255
        valueBaseColor    = zeros(0,4) % [R G B a] from 0 to 255
        
        Xorigin           = zeros(0)   % X coordiantes (in PTB referential) of the origin, in pixels
        Yorigin           = zeros(0)   % Y coordiantes (in PTB referential) of the origin, in pixels
        
        screenX           = zeros(0)   % number of horizontal pixels of the screen
        screenY           = zeros(0)   % number of vertical   pixels of the screen
        
        % Internal variables
        
        frameCurrentColor = zeros(0,4) % [R G B a] from 0 to 255
        diskCurrentColor  = zeros(0,4) % [R G B a] from 0 to 255
        valueCurrentColor = zeros(0,4) % [R G B a] from 0 to 255
        
        Xptb              = zeros(0)   % X coordiantes in PTB referential of the center, in pixels
        Yptb              = zeros(0)   % Y coordiantes in PTB referential of the center, in pixels
        
        R                 = zeros(0)   % distance between (Xorigin,Yorigin) and the circle center
        THETA             = zeros(0)   % angle    between (Xorigin,Yorigin) and the circle center
        
        Rect              = zeros(0,4) % Rectangle for PTB draw Screen('FrameOval') function
        
        filled            = true       % flag to fill or not inside the circle
        valued            = 0          % flag to fill or not inside the circle
        
        value             = 40         % value from 0 to 100, to fill the disk
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Circle( diameter, thickness,  frameColor, diskColor, valueColor, Xorigin, Yorigin, screenX, screenY )
            % obj = FixationCross(
            % diameter=ScreenHeight*0.9 (pixels) ,
            % thickness=5 (pixels) ,
            % frameColor=[128 128 128 255] from 0 to 255 ,
            % diskColor=[128 128 128 255] from 0 to 255 ,
            % value=[0 0 255 255] from 0 to 255 ,
            % Xorigin = CenterX (pixels) ,
            % Yorigin = CenterX (pixels) ,
            % screenX = wRect(3) (pixels) ,
            % screenY = wRect(4) (pixels) )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- diameter ----
                assert( isscalar(diameter) && isnumeric(diameter) && diameter>0 , ...
                    'diameter = diameter of the circle, in pixels' )
                
                % --- thickness ----
                assert( isscalar(thickness) && isnumeric(thickness) && thickness>0 , ...
                    'thickness = thickness of the circle, in pixels' )
                
                % --- frameColor ----
                assert( isvector(frameColor) && isnumeric(frameColor) && all( uint8(frameColor)==frameColor ) , ...
                    'frameColor = [R G B a] from 0 to 255' )
                
                % --- diskColor ----
                assert( isvector(diskColor) && isnumeric(diskColor) && all( uint8(diskColor)==diskColor ) , ...
                    'diskColor = [R G B a] from 0 to 255' )
                
                % --- valueColor ----
                assert( isvector(valueColor) && isnumeric(valueColor) && all( uint8(valueColor)==valueColor ) , ...
                    'valueColor = [R G B a] from 0 to 255' )
                
                % --- Xorigin ----
                assert( isscalar(Xorigin) && isnumeric(Xorigin) && Xorigin>0 && Xorigin==round(Xorigin) , ...
                    'Xorigin = CenterX of the origin, in pixels' )
                
                % --- Yorigin ----
                assert( isscalar(Yorigin) && isnumeric(Yorigin) && Yorigin>0 && Yorigin==round(Yorigin) , ...
                    'Yorigin = CenterX of the origin, in pixels' )
                
                % --- screenX ----
                assert( isscalar(screenX) && isnumeric(screenX) && screenX>0 && screenX==round(screenX) , ...
                    'screenX = number of horizontal pixels of the PTB window' )
                
                % --- screenY ----
                assert( isscalar(screenY) && isnumeric(screenY) && screenY>0 && screenY==round(screenY) , ...
                    'screenY = number of vertical pixels of the PTB window' )
                
                obj.diameter          = diameter;
                obj.thickness         = thickness;
                obj.frameBaseColor    = frameColor;
                obj.frameCurrentColor = frameColor;
                obj.diskBaseColor     = diskColor;
                obj.diskCurrentColor  = diskColor;
                obj.valueBaseColor    = valueColor;
                obj.valueCurrentColor = valueColor;
                obj.Xorigin           = Xorigin;
                obj.Yorigin           = Yorigin;
                obj.screenX           = screenX;
                obj.screenY           = screenY;
                
                % ================== Callback =============================
                
                obj.Move(0,0);
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
