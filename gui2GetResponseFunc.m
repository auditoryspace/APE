function r = gui2GetResponseFunc(r,numbuttons,pos,nocursor,buttontitles,buttonpos)
%function r = gui2GetResponseFunc(r,numbuttons,pos,nocursor,buttontitles,buttonpos)
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
%
% compared to guiGetResponseFunc, gui2GetResponseFunc maintains the GUI
% window between calls.
%
% CS 6/11/10: Added pos, nocursor, buttontitles, and buttonpos to mimic
% behavior of touchline responder
%
% use pos to give window position in pixels
% use nocursor (1 or 0) to hide cursor (good for touch screens)
% use buttontitles to change labeling of buttons (default 1, 2, 3, etc)
%  buttontitles should be a cell array of strings (one per button)
% use buttonpos to specify button positions within window. 
%  buttonpos should be a cell array of position arrays: [l b w h]
% note that buttonpos and button should have length equal to numbuttons
%   otherwise, default values will be used
% 
% default values for pos, nocursor, buttontitles, and buttonpos can also
%   be maintained by setting the argument to empty ([])...in order to
%   access parameters later in the arglist. 

if nargin<6
    buttonpos = {};
    if nargin < 5
        buttontitles = {};
    end
end

if nargin<4 || isempty(nocursor)
    nocursor = 0;
end

if nargin<3 || isempty(pos)
    pos = [];
end

   
respParams = get(r,'params');

% CS 1/16/16. Try to let work with no extra args: r = goGetResponse(r)
if nargin<2 
    numbuttons = length(respParams.guibuttons);
end

if ~isfield(respParams,'guifig') | isempty(respParams.guifig) | ~ismember(respParams.guifig,findobj('name','Select response'))
    % make a GUI figure
    f = figure('name','Select response','menubar','none');
    if isempty(pos)
        p = get(f,'Position');
        p(4) = p(3)./4;
    else
        p = pos;
    end
    set(f,'Position',p);
    
    if nocursor
        set(f,'pointer','custom','pointershapecdata',nan(16),'pointershapehotspot',[9 9]);
    end

    respParams.guifig = f;
    respParams.guibuttons = [];
    r = set(r,'params',respParams); % newfig - replace the buttons
else
    f = get(r,'params','guifig');
end

figure(f);

respParams = get(r,'params');
if ~isfield(respParams,'guibuttons') | length(respParams.guibuttons) ~= numbuttons 
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
        
        if ~isempty(buttonpos) && length(buttonpos)==numbuttons
            set(u(i),'position',buttonpos{i});
        else
            set(u(i),'position',[butleft(i) butbottom butwidth butheight]);
        end

        if ~isempty(buttontitles) && length(buttontitles)==numbuttons
            set(u(i),'string',buttontitles{i});
        end


    end
    r = set(r,'params','guibuttons',u);
else
    u = get(r,'params','guibuttons');
end

for i = 1:length(u)
    set(u(i),'Enable','on'); % now clickable
end

tic % set a timer
% set(f,'Visible','on'); % show the fig
% drawnow; 

% loop to wait for subject response
mydata = [];
while isempty(mydata)
    drawnow;
    mydata = get(f,'UserData'); % clickme will fill f's UserData
end
set(f,'UserData',[]);
%close(f);    % close the fig
% set(f,'Visible','off');    % hide the fig
for i = 1:length(u)
    set(u(i),'Enable','inactive'); % now unclickable
end
figure(f);

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
