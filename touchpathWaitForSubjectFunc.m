function r = touchpathWaitForSubjectFunc(r,msg,msgplacement)
% function r = touchpathWaitForSubjectFunc(r,msg,msgplacement)
% function r = touchpathWaitForSubjectFunc(r)
%
% Put a message on the screen:
%    msg = 'Press anywhere to begin...';
%    msgplacement = {.5 .8 48 'r'};  % x y fontsize color
%
% And wait for subject to click somewhere....

if nargin == 1
    msg = 'Press anywhere to begin...';
    msgplacement = {.5 .8 48 'r'};  % x y fontsize color
end

oldfunc = get(gcf,'WindowButtonDownFcn');
oldud = get(gcf,'userdata');
set(gcf,'WindowButtonDownFcn',@getclick,'userdata',0);


% find the paths axis...
theaxes = get(gcf,'children');
i = find(strcmp(get(theaxes,'tag'),'paths'));
pathax = theaxes(i); 
axes(pathax);

ht = text(msgplacement{1},msgplacement{2},sprintf(msg),'horizontalalignment','center','fontsize',msgplacement{3},'fontname','Comic Sans MS','color',msgplacement{4});

done = 0;

while ~done
    done = get(gcf,'userdata');
    pause(0.1);
end

delete(ht);
set(gcf,'WindowButtonDownFcn',oldfunc,'UserData',oldud);


%%
function getclick(hobject,eventdata)
    set(gcf,'userdata',1);
