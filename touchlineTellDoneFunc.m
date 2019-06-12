function r = touchlineTellDoneFunc(r,numbuttons,pos,nocursor,buttontitles,buttonpos)
%function r = touchlineTellDoneFunc(r,numbuttons,pos,nocursor,buttontitles,buttonpos)
%
% This is a goWaitForSubject function. 
%
% In this case, <r> presents a gui with <numbuttons> buttons (default 2).
% include argument <pos> to define window position
% set agument <nocursor> to 1 to hide cursor in window
% <buttontitles> : option cell array of strings to title each drawn axis
%   length must match numbuttons
% <buttonpos> : optional cell array of position vectors (normalized to
%   figure dims) for each button. length must match numbuttons
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
if nargin<4 || isempty(nocursor)
    nocursor = 0;
end

clear buttontitles;
[buttontitles{1:numbuttons}] = deal('All Done');

respParams = get(r,'params');
if ~isfield(respParams,'guifig') | isempty(respParams.guifig) | ~ismember(respParams.guifig,findobj('name','Select response'))
    % make a GUI figure
    f = figure('name','Select response','menubar','none');
    if nargin<3 || isempty(pos)

        pos = get(f,'Position');
        pos(4) = pos(3)./4;
    end

    set(f,'Position',pos);
    
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
    marginTB = .2; % margin at Top and Bottom
    marginBB = .2; % margin Between Buttons
    butwidth = 1-2.*marginLR;
    butleft  = marginLR;
    butheight = (1-(2.*marginTB)-(numbuttons-1).*marginBB)./numbuttons;
    butbottom = linspace(1-marginTB-butheight,marginTB,numbuttons);


    % make the buttons (really just empty axes). note the callback, clickme, is defined below
    for i = 1:numbuttons
        u(i) = axes('units','normalized','buttondownfcn',@clickme,'tag',num2str(i));
           
        if nargin>=6 && length(buttonpos)==numbuttons
           set(u(i),'position',buttonpos{i});
        else
            set(u(i),'position',[butleft butbottom(i) butwidth butheight]);
        end

        axis([0 1 0 1]);
        set(u(i),'xtick',[],'Ytick',[],'box','on');
        if nargin>=5 && length(buttontitles)==numbuttons
            title(buttontitles{i});
        end
    
    end
    r = set(r,'params','guibuttons',u);
else
    u = get(r,'params','guibuttons');
end

for i = 1:length(u)
    title('All Done');
end

% alert the operator  ... CS 6/8/10
for i = 1:2, beep; pause(0.8); end

% for i = 1:length(u)
%     set(u(i),'Enable','on'); % now clickable
% end

% set(f,'UserData',[]);
 tic % set a timer
% % set(f,'Visible','on'); % show the fig
% % drawnow; 
% 
% % loop to wait for subject to read message
% while toc < 2
%     drawnow;
% end
% set(f,'UserData',[]);
%close(f);    % close the fig
% set(f,'Visible','off');    % hide the fig

% for i = 1:length(u)
%     set(u(i),'Enable','inactive'); % now unclickable
% end


%r = set(r,'respData',mydata);  % set the data and return

%%% ------------------------------------------------------------------
%%% clickme - the button callback
%%% ------------------------------------------------------------------
function mydata = clickme(varargin)

rt = toc; % measure reaction time
mydata.button = str2num(get(gcbo,'tag')); % figure out what button was pressed
mydata.reactiontime = rt;
cp = get(gca,'CurrentPoint');

mydata.x = cp(1,1);
mydata.y = cp(1,2);
% fprintf('clicked axis %d at (%.2f,%.2f) after %.3f seconds\n',mydata.button,...
%     mydata.x,mydata.y,mydata.reactiontime)
set(get(gcbo,'Parent'),'UserData',mydata); % store the data in the GUI figure
