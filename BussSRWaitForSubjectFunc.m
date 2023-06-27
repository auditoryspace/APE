function r = BussSRWaitForSubjectFunc(r,pos,nocursor)
%function r = BussSRWaitForSubjectFunc(r,pos,nocursor)
%
% BussSR is an APE module implementing Emily Buss' Sentence Response
% interface for sentences with keywords. As part of APE, this code is (c)
% 2023, Auditory Space, LLC but includes code from Emily Buss and should be
% credited thusly. Please inquire regarding how to properly cite this work.
%
% The APE responder class provides an abstract definition of particpant
% response interface, consisting primarily of the following function
% handles: 
%
%   prepResponseFunc      % prepares the response (reset/redraw/etc)
%   getResponseFunc      % records and returns the response data
%   presentFeedbackFunc  % presents feedback (colors buttons, lights LEDs)
%   waitForSubjectFunc   % basic response, waiting to begin trial
%   tellDoneFunc         % communicate end of run to participant
%
% This function, BussSRWaitForSubjectFunc, sets up the response window 
% with a single button to begin when ready
%
% use pos to give window position in pixels
% use nocursor (1 or 0) to hide cursor (good for touch screens)
% 
% default values for pos and nocursor can also
%   be maintained by setting the argument to empty ([])...in order to
%   access parameters later in the arglist. 


if nargin<3 || isempty(nocursor)
    nocursor = 0;
end

if nargin<2 || isempty(pos)
    pos = [];
end


%% create the figure  
IDString = sprintf('BussSR: %s','WAITING'); % note Emily's had SNR and trial number in response GUI also

% have a default color for the figure. 
respParams = get(r,'params');
if ~isfield(respParams,'fieldColor') || isempty(respParams.fieldColor)
    respParams.fieldColor = [.7 .7 .7]; % default gray
end

if ~isfield(respParams,'guifig') || isempty(respParams.guifig) || ~ismember(respParams.guifig,findobj('-regexp','name','BussSR*'))
    % make a GUI figure
%     f = figure('name','Select response','menubar','none');
    HANDLES.f = figure('Units','points', ...
        'Color',respParams.fieldColor, ... % define in respParams? 
        'MenuBar','none', ...
        'Name',IDString,...
        'Tag','',...                            % default none missed
        'ToolBar','none');
    
    if isempty(pos)
        p = get(HANDLES.f,'Position');
%         p(4) = p(3)./4;
    else
        p = pos;
    end
    set(HANDLES.f,'Position',p);
    
    if nocursor
        set(HANDLES.f,'pointer','custom','pointershapecdata',nan(16),'pointershapehotspot',[9 9]);
    end

    respParams.guifig = HANDLES.f;
    respParams.guibuttons = [];
    respParams.HANDLES = HANDLES;
     r = set(r,'params',respParams); % newfig - replace the buttons
else
    HANDLES.f = get(r,'params','guifig'); % use existing figure
    clf(HANDLES.f);  % but clear it
    set(HANDLES.f,'Name',IDString,'Tag','')
    r = set(r,'params',respParams); 

end

figure(HANDLES.f);

WIN.pos = get(HANDLES.f,'position');
WIN.width = WIN.pos(3);
WIN.height = WIN.pos(4);

%% some constants. These should probably be defined as input parameters
% CONST.LetterWidth = 
% CONST.LetterHeight = 
% CONST.SentFontSize = 
CONST.SentFontSize = 30;
CONST.LetterWidth = 18;
CONST.LetterHeight = 30;


% CONST.BackGroundColor = 
% CONST.FlagColor = 
% CONST.FieldColor = [0.85,0.85,0.85];	% LIGHT GREY: color of figure background
CONST.TextColor = [0,0,0];				% BLACK: color of sentence text
CONST.BackGroundColor = [1,1,1];		% WHITE: color of keyword background
CONST.FlagColor = [1,0.65,0.80];		% PINK: color of keyword, flagged

CONST.ButtonColor = [1,1,0.75];			% YELLOW: color of button background
CONST.ButtonFontSize = 14;
CONST.ButtonWidth = 0.15;
CONST.ButtonYpts = [0.1,0.1];

%% set up a message
% y(1) = WIN.height/2;
% y(2) = CONST.LetterHeight;
% 
% posit = [WIN.width.*.2, y(1),...
%     WIN.width.*.6, y(2)];
HANDLES.textMsg = uicontrol('Parent',HANDLES.f,...
    'BackgroundColor',get(HANDLES.f,'Color'), ...
    'Units','normalized',...
    'FontSize',CONST.SentFontSize,...
    'fontname','courier',...
    'style','text',...
    'Position',[.2 .5 .6 .2],...
    'string','Click to Begin');

%% SET UP "DONE" BUTTON
ButtonPad = (1-3*CONST.ButtonWidth)/4;

LeftButtonEdge = 2*ButtonPad + CONST.ButtonWidth;
posit = [LeftButtonEdge,CONST.ButtonYpts(1),...
    CONST.ButtonWidth,CONST.ButtonYpts(2)];
HANDLES.Done = uicontrol('Parent',HANDLES.f,...
    'BackgroundColor',CONST.ButtonColor, ...
    'Units','normalized',...
    'FontSize',CONST.ButtonFontSize,...
    'fontname','courier',...
    'style','pushbutton',...
    'Position',posit,...
    'string','READY');

set(HANDLES.Done,'Callback',...
    @(src,evnt)ButtonAct(HANDLES.Done,...
    CONST.BackGroundColor,'done'));

while isempty(get(HANDLES.f,'UserData'))
    pause(0.1);
end

%% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% ButtonAct - the button callback
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function ButtonAct(h,ButtonColor,cmd_in)
        
        % change the button color when pressed
        for i = 1:length(h)        % set button color
            set(h(i),'backgroundcolor',ButtonColor);
        end
        
        if nargin < 3
            return;
        end
        
        % next, what to do depends on the command
        if isnumeric(cmd_in)
            for i = 1:length(cmd_in)                          % record resp (words missed)
                TagStr = get(get(h(1),'Parent'),'Tag');         % unless already recorded
                if isempty(strfind(TagStr,num2str(cmd_in(i))))
                    TagStr = [TagStr,num2str(cmd_in(i)),','];
                    set(get(h(1),'Parent'),'Tag',TagStr); % store the data in the GUI figure
                end
            end
        else
            
            switch cmd_in
                case 'clear'
                    set(get(h(1),'Parent'),'Tag','');                   % remove prev resp
                case 'done'
                    fprintf('Starting...\n');
                    TagStr = get(get(h(1),'Parent'),'Tag');
                    TagStr = [TagStr,'DONE'];                           % indicate resp complete
                    set(get(h(1),'Parent'),'UserData',TagStr); % push tag into userdate so APE knows response is ready
                   set(get(h(1),'Parent'),'Tag',''); % but clear the tag itself
                    
            end
        end
        
        
        
    end                             % end of ButtonAct

end
