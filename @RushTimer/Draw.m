function Draw( self , value )

self.valueCurrent = value;

%% Scale the value

self.ratioCurrent = ( value - self.valueMin ) / ( self.valueMax - self.valueMin );

%% Get the color

self.colorCurrent = self.colorScale( round(255 * self.ratioCurrent) + 1 ,:);

%% Generate the rect

self.rectCurrent = AlignRect ( [0 0 self.screenX*self.ratioCurrent self.screenY*self.heightRatio] , self.rectBase , 'left' , 'bottom' );

%% Draw

Screen( 'FillRect' , self.wPtr , self.colorCurrent , self.rectCurrent);

end % end
