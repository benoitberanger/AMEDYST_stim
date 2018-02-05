classdef Image < baseObject
    %IMAGE Class to load, prepare and display images in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        filename  % image file path
        scale = 1 % scale of the image => 1 means original image
        center    % [X-center-PTB, Y-center-PTB]
        
        % Internal variables
        
        X     % matrix image
        map   % colormap
        alpha % alpha chanel
        baseRect    % original rectangle for PTB
        currentRect % current  rectangle for PTB
        
        texturePtr % PTB texure pointer
        
        
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = Image( filename, center, scale )
            % obj = Image( filename, center, scale )
            
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
                
                
                % ================== Callback =============================
                
                if nargin > 1 && ~isempty(center)
                    self.Move(center);
                end
                
                if nargin > 2 && ~isempty(scale)
                    self.Rescale(scale);
                end
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
