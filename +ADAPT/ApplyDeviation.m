function [ dXc, dYc ] = ApplyDeviation( prevX, prevY, newX, newY, deviation )

dX = newX - prevX; % pixels
dY = newY - prevY; % pixels

dR     = sqrt(dX*dX + dY*dY); % pixels
dTheta = atan2(dY,dX);        % rad

dXc = dR * cos(dTheta + deviation*pi/180); % pixels
dYc = dR * sin(dTheta + deviation*pi/180); % pixels

end % function
