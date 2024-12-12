function r = BussSRPrepResponseFunc(r,tokenInfo,pos,nocursor)
%function r = BussSRPrepResponseFunc(r,tokenInfo,pos,nocursor)
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
% This function, BussSRprepResponseFunction, sets up the response window 
% according to the information in the structure <tokenInfo>:'
%
% Alternate (3/8/23)
%     Sentence: 'He dreamed of being in a rock band'
%       Label: 'List1, sentence1'
%    NumWords: 8
%    KeyWords: [1 1 0 1 1 0 1 1]
%       Words: {'He' 
%               'dreamed'
%               'of'
%               'being'
%               'in'
%               'a'
%               'rock'
%               'band'}
%
% Label, if empty, defaults to 'unknown'
%
% Note that if tokenInfo does not contain the field 'Words', it will be
% computed from 'Sentence', using spaces as delimiters and assigning one
% cell element to each intervening word. 
%
% NumWords, if empty, defaults to length of Words
%
% KeyWords, if empty, defaults to  treating all words as key words (e.g., [1 1 1 1 1]).
%
% Response data are based on the number of key words correctly and
% incorrectly identified.
%
% The interface consists of toggleable buttons for each word in the
% sentence, along with buttons to select all or none, and to enter/record 
% the response. 
%
% use pos to give window position in pixels
% use nocursor (1 or 0) to hide cursor (good for touch screens)
% 
% default values for pos and nocursor can also
%   be maintained by setting the argument to empty ([])...in order to
%   access parameters later in the arglist. 
%
% (c) 2023 Auditory Space, LLC


if nargin<4 || isempty(nocursor)
    nocursor = 0;
end

if nargin<3 || isempty(pos)
    pos = [];
end

if ischar(tokenInfo)
    tokenInfo = struct('Sentence',tokenInfo);
end

ThisWord = 'dummy';         % initialize

% compute Words list from Sentence if necessary
if ~isfield(tokenInfo,'Words')
    foo = textscan(tokenInfo.Sentence,'%s','delimiter',' ','multipledelimsasone',1);
    tokenInfo.Words = foo{1};
end

if ~isfield(tokenInfo,'NumWords')
    tokenInfo.NumWords = length(tokenInfo.Words);
end

if ~isfield(tokenInfo,'Label')
    tokenInfo.Label = 'unknown';
end


AllWords = 1:tokenInfo.NumWords;
if ~isfield(tokenInfo,'KeyWords') || isempty(tokenInfo.KeyWords)
    tokenInfo.KeyWords = ones(1,tokenInfo.NumWords);
end

keyWords = AllWords(tokenInfo.KeyWords==1);

% now do some error checking
% first lets do some checking before retuning
if length(tokenInfo.Words) ~= tokenInfo.NumWords || tokenInfo.NumWords ~= length(tokenInfo.KeyWords)
    error('Sentence length does not match keywords');
end


%% create the figure  
try
IDString = sprintf('BussSR: %s',tokenInfo.Label); % note Emily's had SNR and trial number in response GUI also
catch 
    IDString = sprintf('BussSR: %s',tokenInfo.Label{1}); % note Emily's had SNR and trial number in response GUI also
end

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
    respParams.tokenInfo = tokenInfo;
    r = set(r,'params',respParams); % newfig - replace the buttons
else
    HANDLES.f = get(r,'params','guifig'); % use existing figure
    set(HANDLES.f,'UserData',[]);
    clf(HANDLES.f);  % but clear it
    set(HANDLES.f,'Name',IDString,'Tag','')
    respParams.tokenInfo = tokenInfo;
    r = set(r,'params',respParams);
    r = set(r,'respData',[]); 

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

%% CONFIGURE SENTENCE DISPLAY
for loop = 1:tokenInfo.NumWords	% determine total length of sentence
%     thisWord = tokenInfo.(sprintf('w%d',loop));    
    thisWord = tokenInfo.Words{loop};
    
%     eval(['ThisWord = TokenInfo.w',num2str(loop),';']);
    if loop == 1,	x(1) = 0;
    else x(1) = x(1)+x(2);
    end
    x(2) = (CONST.LetterWidth*(length(thisWord)+1));
end
marginAvailable = WIN.width-(x(1)+x(2));

y(1) = WIN.height/2;
y(2) = CONST.LetterHeight;

% create the word buttons
for loop = 1:tokenInfo.NumWords	% put words & corresponding buttons into the figure
    thisWord = tokenInfo.Words{loop};
    
    if loop == 1,	x(1) = marginAvailable/2;
    else x(1) = x(1)+x(2);
    end
    
    x(2) = (CONST.LetterWidth*(length(thisWord)+1));
    
    HANDLES.b(loop) = uicontrol(...
        'Parent',HANDLES.f,...
        'Units','points',...
        'FontSize',CONST.SentFontSize,...
        'fontname','courier',...
        'position',[x(1) y(1) x(2) y(2)]);		%left, bottom, width, height
    
    if tokenInfo.KeyWords(loop)
        CallBackStr = @(src,evnt)ButtonAct(HANDLES.b(loop),CONST.FlagColor,loop);
        set(HANDLES.b(loop),'Callback',CallBackStr,...
            'style','pushbutton',...
            'BackgroundColor',CONST.BackGroundColor);
    else
        ButtonAct(HANDLES.b(loop),CONST.BackGroundColor);
        set(HANDLES.b(loop),'style','text',...
            'BackgroundColor',CONST.FieldColor);
    end
    
    set(HANDLES.b(loop),'string',thisWord);
    
end

%% SET UP "CLEAR" BUTTON
ButtonPad = (1-3*CONST.ButtonWidth)/4;
LeftButtonEdge = ButtonPad;
posit = [LeftButtonEdge,CONST.ButtonYpts(1),...
    CONST.ButtonWidth,CONST.ButtonYpts(2)];
HANDLES.Reset = uicontrol('Parent',HANDLES.f,...
    'BackgroundColor',CONST.ButtonColor, ...
    'Units','normalized',...
    'FontSize',CONST.ButtonFontSize,...
    'fontname','courier',...
    'style','pushbutton',...
    'Position',posit,...
    'string','RESET');

set(HANDLES.Reset,'Callback',...
    @(src,evnt)ButtonAct(HANDLES.b(keyWords),...
    CONST.BackGroundColor,'clear'));


%% SET UP "DONE" BUTTON
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
    'string','DONE');

set(HANDLES.Done,'Callback',...
    @(src,evnt)ButtonAct(HANDLES.b(keyWords),...
    CONST.BackGroundColor,'done'));

%% SET UP "MISSED ALL" BUTTON
LeftButtonEdge = 3*ButtonPad + 2*CONST.ButtonWidth;
posit = [LeftButtonEdge,CONST.ButtonYpts(1),...
    CONST.ButtonWidth,CONST.ButtonYpts(2)];
HANDLES.MissAll = uicontrol('Parent',HANDLES.f,...
    'BackgroundColor',CONST.ButtonColor, ...
    'Units','normalized',...
    'FontSize',CONST.ButtonFontSize,...
    'fontname','courier',...
    'style','pushbutton',...
    'Position',posit,...
    'string','ALL WRONG');

set(HANDLES.MissAll,'Callback',...
    @(src,evnt)ButtonAct(HANDLES.b(keyWords),...
    CONST.FlagColor,keyWords));

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
                    TagStr = get(get(h(1),'Parent'),'Tag');
                    TagStr = [TagStr,'DONE'];                           % indicate resp complete
                    set(get(h(1),'Parent'),'UserData',TagStr); % push tag into userdate so APE knows response is ready
                   set(get(h(1),'Parent'),'Tag',''); % but clear the tag itself
                    
            end
        end
        
        
        
    end                             % end of ButtonAct

end
