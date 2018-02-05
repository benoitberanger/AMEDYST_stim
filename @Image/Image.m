classdef Image < baseObject
    %IMAGE Class to load, prepare and display images in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        filename  % image file path
        scale = 1 % scale of the image => 1 means original image
        center    % [X-center-PTB, Y-center-PTB]
        baseColor % color of the the image rect, when you don't want to draw the image but just it's frame
        
        % Internal variables
        
        X     % matrix image
        map   % colormap
        alpha % alpha chanel
        baseRect    % original rectangle for PTB
        currentRect % current  rectangle for PTB
        
        texturePtr % PTB texure pointer
        
        currentColor % color of the the image rect, when you don't want to draw the image but just it's frame
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = Image( filename, center, scale, color )
            % obj = Image( filename, center, scale, color )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                assert( exist(filename,'file')>0 , '%s cannot be found' )
                
                [X, map, alpha] = imread(filename);
                
                self.filename = filename;
                
                self.X     = X    ;
                self.map   = map  ;
                self.alpha = alpha;
                
                self.baseRect                    = [0 0 size(X,1) size(X,2)];
                [self.center(1), self.center(2)] = RectCenter(self.baseRect);
                self.GenerateRect;
                
                self.baseColor    = [ 0 0 0 ]; % [ R G B ] form 0 to 255
                self.currentColor = self.baseColor;
                
                % ================== Callback =============================
                
                if nargin > 1 && ~isempty(center)
                    self.Move(center);
                end
                
                if nargin > 2 && ~isempty(scale)
                    self.Rescale(scale);
                end
                
                if nargin > 3 && ~isempty(color)
                    self.baseColor    = color;
                    self.currentColor = color;
                end
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
