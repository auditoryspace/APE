function r = touchlinePresentFeedbackFunc(r,numbuttons,correctbut)
%function r = touchlinePresentFeedbackFunc(r,numbuttons,correctbut)
%
% This is the default presentFeedback function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, make a gui with <numbuttons> buttons and color them
% green if r.respdata indicates correct response, red if not.
%
% Note that another approach would be to maintain the GUI in r.params and
% only change its appearance (rather than building from scratch) in
% getResponse and presentFeedback functions
%
% invoked by r = goPresentFeedback(r,varargin)

buttoncolors = cell(1,numbuttons);
respbut = get(r,'respData','button');
if correctbut == 0
    buttoncolor = 'k';
elseif respbut == correctbut
    buttoncolor = 'g';
else
    buttoncolor = 'r';
end

% make a GUI figure
f = get(r,'params','guifig');
u = get(r,'params','guibuttons');

figure(f);

% if nargin<4
%     % set(f,'Visible','on');
%     oldcolor = get(u(correctbut),'Color');
%     set(u(correctbut),'Color',buttoncolor);
%     pause(1)
%     set(u(correctbut),'Color',oldcolor);
%     % set(f,'Visible','off');
% else
%     axes(u(respbut));
%     l = line(x,y,'marker','*','color',buttoncolor,'markersize',18);
%     pause(1);
%     delete(l);
%end


    x = get(r,'respData','x');
    y = get(r,'respData','y');
    axes(u(respbut));
    %%% Change to markersize made by Andrew, 1/6/12, to remediate display
    %%% error that occurs when subjects touch very near the button border.
    %l = line(x,y,'marker','*','LineWidth',3,'color',buttoncolor,'markersize',6);
    
    % Note that the above marker was a distractingly odd shape, due to
    % presence of thick line to one corner of symbol. We should do more to
    % understand the "display error" and fix it a different way.
    % UPDATE: Error seems to be that response position can read as slightly
    % negative, which falls outside of the axis range (no visible marker)
    % Fixed in touchlineGetResponseFunc.m (force x,y to range [0 1])
    % returned to original, CS 3/27/12. 
    l = line(x,y,'marker','*','color',buttoncolor,'markersize',18);
    
    pause(1);
    delete(l);
