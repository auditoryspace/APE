function r = touchpathTellDoneFunc(r,msg,msgplacement)
% function r = touchpathTellDoneFunc(r,msg,msgplacement)
% function r = touchpathTellDoneFunc(r)
%
% Put a message on the screen:
%    msg = 'Press anywhere to begin...';
%    msgplacement = [.5 .8 48];  % x y fontsize
%
% Wait two seconds, then return

if nargin == 1
    msg = 'All done.';
    msgplacement = {.5 .8 48 'r'};  % x y fontsize color
end




% find the paths axis...
% theaxes = get(gcf,'children');
theaxes = get(r,'params','guibuttons');
i = find(strcmp(get(theaxes,'tag'),'paths'));
pathax = theaxes(i); 
axes(pathax);

ht = text(msgplacement{1},msgplacement{2},msg,'horizontalalignment','center','fontsize',msgplacement{3},'fontname','Comic Sans MS','color',msgplacement{4});

    pause(2);

delete(ht);
