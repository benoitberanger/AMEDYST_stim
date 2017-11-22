classdef Dot < baseObject
    %DOT Class to prepare and draw a dot==cursor in PTB
    
    %% Properties
    
    properties
        
        % Parameters for the creation
        
        diameter          = zeros(0)   % in pixels
        
        Xorigin           = zeros(0)   % X coordiantes (in PTB referential) of the origin, in pixels
        Yorigin           = zeros(0)   % Y coordiantes (in PTB referential) of the origin, in pixels
        
        screenX           = zeros(0)   % number of horizontal pixels of the screen
        screenY           = zeros(0)   % number of vertical   pixels of the screen
        
        diskBaseColor     = zeros(0,4) % [R G B a] from 0 to 255
        diskCurrentColor  = zeros(0,4) % [R G B a] from 0 to 255
        
        % Internal variables
        
        X                 = zeros(0)   % X coordiantes from (Xorigin,Yorigin), in pixels
        Y                 = zeros(0)   % Y coordiantes from (Xorigin,Yorigin), in pixels
        
        Xptb              = zeros(0)   % X coordiantes in PTB referential of the center, in pixels
        Yptb              = zeros(0)   % Y coordiantes in PTB referential of the center, in pixels
        
        Rect              = zeros(0,4) % Rectangle for PTB draw Screen('FrameOval') function
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Dot( diameter, diskColor, Xorigin, Yorigin, screenX, screenY )
            % obj = FixationCross(
            % diameter=ScreenHeight*0.9 (pixels) ,
            % diskColor=[128 128 128 255] from 0 to 255 ,
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
                
                % --- diskColor ----
                assert( isvector(diskColor) && isnumeric(diskColor) && all( uint8(diskColor)==diskColor ) , ...
                    'diskColor = [R G B a] from 0 to 255' )
                
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
                obj.diskBaseColor     = diskColor;
                obj.diskCurrentColor  = diskColor;
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
