function r = guiPresentFeedbackFunc(r,numbuttons,correctbut)
%function r = guiPresentFeedbackFunc(r,numbuttons,correctbut)
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
if respbut == correctbut
    buttoncolors{correctbut} = 'g';
else
    buttoncolors{correctbut} = 'r';
end

% make a GUI figure
f = figure('name','Select response','menubar','none');
p = get(f,'Position');
p(4) = p(3)./4;
set(f,'Position',p);

% calculate positions for the buttons in the GUI
marginLR = .05; % margin at Left and Right
marginTB = .12; % margin at Top and Bottom
marginBB = 0.01; % margin Between Buttons
butwidth = (1-(2.*marginLR)-(numbuttons-1).*marginBB)./numbuttons;
butleft = linspace(marginLR,1-marginLR-butwidth,numbuttons);
butheight = 1-2.*marginTB;
butbottom = marginTB;

% make the buttons. note the callback, clickme, is defined below
for i = 1:numbuttons
    u(i) = uicontrol('units','normalized',...
        'position',[butleft(i) butbottom butwidth butheight],...
        'fontunits','normalized','fontsize',0.8,...
        'string',num2str(i));
    if ~isempty(buttoncolors{i})
        set(u(i),'BackGroundColor',buttoncolors{i});
    end
end


pause(1)

close(f);