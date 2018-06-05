classdef RushTimer < baseObject
    %RUSHTIMER Class to prepare and draw a time in PTB
    
    
    %% Properties
    
    properties
        
        % Parameters
        
        valueMin    = zeros(0) % minimum value
        valueMax    = zeros(0) % maximum value
        
        screenX     = zeros(0) % number of horizontal pixels of the screen
        screenY     = zeros(0) % number of vertical   pixels of the screen
        
        heightRatio = zeros(0) % timer height will be heightRatio*screenY
        
        % Internal variables
        
        valueCurrent = zeros(0)   % current value, will use min and max to compute rectangle==timer diemensions
        ratioCurrent = 255        % valueCurrent -> ratioCurrent from 0 to 255 (for the color scale)
        
        rectBase     = zeros(0,4) % base rectangle in PRB coordinates
        rectCurrent  = zeros(0,4) % current rectangle in PRB coordinates
        
        colorScale   = jet(256)   % color table
        colorCurrent = zeros(0,3) % [R G B] from 0 to 255
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = RushTimer(min , max, width, height, ratio)
            
            % Arguments ?
            if nargin > 0
                
                self.valueMin    = min;
                self.valueMax    = max;
                self.screenX     = width;
                self.screenY     = height;
                self.heightRatio = ratio;
                
                % ================== Callback =============================
                
                self.valueCurrent = self.valueMax;
                
                self.rectBase     = [0 self.screenY*(1-self.heightRatio) self.screenX self.screenY];
                self.rectCurrent  = self.rectBase;
                
                self.colorScale   = flipud(self.colorScale) * 255;
                self.colorCurrent = self.colorScale(self.ratioCurrent);
                
            else
                % Create empty instance
            end
            
            
        end % ctor
        
        
    end % methods
    
    
end % class
