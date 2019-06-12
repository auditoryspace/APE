function r = gui2PresentFeedbackFunc(r,numbuttons,correctbut)
%function r = gui2PresentFeedbackFunc(r,numbuttons,correctbut)
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

% CS 1/16/16: try to get work with fewer args: r = goPresentFeedback(r,1)
respParams = get(r,'params');
if nargin < 3
    correctbut = numbuttons;
    numbuttons = length(respParams.guibuttons);
elseif isempty(numbuttons)
    numbuttons = length(respParams.guibuttons);
end

buttoncolors = cell(1,numbuttons);
respbut = get(r,'respData','button');
if respbut == correctbut
    buttoncolor = 'g';
else
    buttoncolor = 'r';
end

% make a GUI figure
f = get(r,'params','guifig');
u = get(r,'params','guibuttons');

figure(f);

% set(f,'Visible','on');
oldcolor = get(u(correctbut),'BackGroundColor');
set(u(correctbut),'BackGroundColor',buttoncolor);
pause(1)
set(u(correctbut),'BackGroundColor',oldcolor);
% set(f,'Visible','off');
