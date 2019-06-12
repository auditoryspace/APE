function bigRedButton
% put a big red button over the full main screen. when clicked, its window
% will disappear. 
%
% This is useful to alert the operator that a run has finished

windowpos = get(0,'screensize');
alertfig = figure('position',windowpos,'menubar','none');
thebutton = uicontrol(alertfig,'Style','pushbutton',...
    'backgroundcolor',[1 0 0],'position',windowpos,...
    'String','Done','fontsize',windowpos(4)./2,...
    'Callback',@closefig);

figure(alertfig);

for i = 1:3
    try
        pause(0.5);
        set(thebutton,'backgroundcolor',[1 1 1]); drawnow
        pause(0.5);
        set(thebutton,'backgroundcolor',[1 0 0]); drawnow
    end
end

function closefig(hobj,eventdata)
close(get(hobj,'parent'));

