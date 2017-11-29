function joymex2_test

running = 1;

% Initialize joystick
joymex2('open',0);

% Create figure and attach close function
figure('CloseRequestFcn',@onClose);

% Create plots
subplot(1,2,1)
p1=plot([0],[0],'x'); hold on;
p2=plot([0],[0],'+r');
p3=plot([0],[0],'og');
title(sprintf('Device 0\nAxis'))
axslims = [double(intmin('int16'))-10 double(intmax('int16'))+10];
set(gca,'xlim',axslims,'ylim',axslims); axis square

%     subplot(2,2,2)
%     h1=plot([0],[0],'x');
%     title('Hats')
%     set(gca,'xlim',[-2 2],'ylim',[-2 2]); axis square

subplot(1,2,2)
% b1=bar(zeros(1,8));
b1=bar(zeros(1,3));
title('Button States')
% set(gca,'xlim',[0 9],'ylim',[0 1]); axis square
set(gca,'xlim',[0 4],'ylim',[0 1]); axis square


while(running)
    % Query postion and button state of joystick 0
    a = joymex2('query',0);
    
    % Update the plots
    
    % Notice the usage of minus signs to invert certain axis values.
    % Depending on the device you may want to change these
    % (The plots are originally configured for a Xbox 360 Controller)
    set(p1,'Xdata',a.axes(1),'Ydata',-a.axes(2));
    %         set(p2,'Xdata',a.axes(5),'Ydata',-a.axes(4));
    %         set(p3,'Xdata',0,'Ydata',a.axes(3));
    set(b1,'Ydata',a.buttons);
    %         set(h1,'Xdata',a.hats.right -  a.hats.left,'Ydata',a.hats.up - a.hats.down);
    
    fprintf('%d %d \n',a.axes(1),-a.axes(2))
    
    % Force update of plot
    drawnow
end

% Clear MEX-file to release joystick
% joymex2('close',0); WARNING : dont use this methode, its not stable !!
clear joymex2

    function onClose(src,evt)
        % When user tries to close the figure, end the while loop and
        % dispose of the figure
        running = 0;
        delete(src);
    end % function

end % function
