function r = guiGetResponseFunc(r,numbuttons)
%function r = guiGetResponseFunc(r,numbuttons)
%
% This is a getResponse function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, <r> presents a gui with <numbuttons> buttons (default 2).
% After this call, r.respdata will have the following structure:
%   button: (button pressed by subject)
%   reactiontime: (time from function call to button press, in seconds)
%
% Note that this code can be easily modified to take more arguments and
% use more involved GUI objects. 
%
% invoked by r = goGetResponse(r,varargin)

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
    u(i) = uicontrol('units','normalized','callback',@clickme,...
        'position',[butleft(i) butbottom butwidth butheight],...
        'fontunits','normalized','fontsize',0.8,...
        'tag',num2str(i),'string',num2str(i));
end

tic % set a timer

% loop to wait for subject response
mydata = [];
while isempty(mydata)
    drawnow;
    mydata = get(f,'UserData'); % clickme will fill f's UserData 
end
close(f);    % close the fig
r = set(r,'respData',mydata);  % set the data and return

%%% ------------------------------------------------------------------
%%% clickme - the button callback
%%% ------------------------------------------------------------------
function mydata = clickme(varargin)

rt = toc; % measure reaction time
mydata.button = str2num(get(gcbo,'tag')); % figure out what button was pressed
mydata.reactiontime = rt;
fprintf('clicked button %d after %.3f seconds\n',mydata.button,mydata.reactiontime)
set(get(gcbo,'Parent'),'UserData',mydata); % store the data in the GUI figure