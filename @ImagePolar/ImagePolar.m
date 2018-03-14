classdef ImagePolar < Image
    %IMAGE Class to load, prepare and display images in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        Xorigin           = zeros(0)   % X coordiantes (in PTB referential) of the origin, in pixels
        Yorigin           = zeros(0)   % Y coordiantes (in PTB referential) of the origin, in pixels
        
        screenX           = zeros(0)   % number of horizontal pixels of the screen
        screenY           = zeros(0)   % number of vertical   pixels of the screen
        
        % Internal variables
        
        Xptb              = zeros(0)   % X coordiantes in PTB referential of the center, in pixels
        Yptb              = zeros(0)   % Y coordiantes in PTB referential of the center, in pixels
        
        R                 = zeros(0)   % distance between (Xorigin,Yorigin) and the circle center
        THETA             = zeros(0)   % angle    between (Xorigin,Yorigin) and the circle center
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = ImagePolar( filename, Xorigin, Yorigin, screenX, screenY )
            % obj = ImagePolar( ... )
            
            % Call SuperClass constructor
            self = self@Image(filename);
            
            % ================ Check input argument =======================
            
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
            
            self.Xorigin = Xorigin;
            self.Yorigin = Yorigin;
            self.screenX = screenX;
            self.screenY = screenY;
            
            % ================== Callback =============================
            
            self.Move(0,0);
            
        end
        
        
    end % methods
    
    
end % class
