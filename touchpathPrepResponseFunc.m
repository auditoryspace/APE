function r = touchpathPrepResponseFunc(r,numbuttons,windowpos,nocursor,buttontitles,buttonpos,xtick,ytick)
%function r = touchpathPrepResponseFunc(r,numbuttons,windowpos,nocursor,buttontitles,buttonpos,xtick,ytick)
%function r = touchpathPrepResponseFunc(r,numbuttons,windowpos,nocursor,buttontitles,buttonpos,imagedata)
%function r = touchpathPrepResponseFunc(r,numbuttons,windowpos,nocursor,buttontitles,buttonpos,imagedata,options)
%
% This is a prepResponse function. Such functions take a responder
% object <r> as the first argument.
%
% In this case, the other arguments match those of touchpathGetResponseFunc
%   with the idea that calling this function will simply generate the
%   response window and buttons.
%
% In this case, <r> presents a gui with <numbuttons> buttons (default 3).
% Currently, touchpath responders should always have 3 buttons. See below.
%
% include argument <windowpos> to define window position
% set agument <nocursor> to 1 to hide cursor in window
% <buttontitles> : option cell array of strings to title each drawn axis
%   length must match numbuttons
% <buttonpos> : optional cell array of position vectors (normalized to
%   figure dims) for each button. length must match numbuttons
% <xtick>, <ytick>: optional array of locs for tic marks. leave off or
%   empty to keep buttons blank. Use values 0 (left/bottom) to 1 (top/right)
% <imagedata> is a cell array corresponding to the buttons. Each element
%   should be a matrix, which will be drawn into the button (which is really
%   an axis, remember?)using image(). If this works, clicks will pass
%   through to the axis (I mean button) and the image is just for
%   decoration.
%
% MODIFIED FROM touchlineGetResponseFunc.m (CS 9/9/15)
%
% touchpath operates differently from touchline. Instead of returning a
%   single point, this allows the user to draw one or more paths on the
%   axis corresponding to button 1.
% There must be exactly 3 buttons.
% Button 1 is where the paths be drawn  (this is an axes)
% Button 2 clears the path data (this is a button)
% Button 3 enters the paths into r.respdata and returns (this is a button)
%
% If <options> is included, should be a cell array of name,value pairs:
% {'showok',1,'showclear',1,'pointsonly',0}
%   showok: if 0, hide ok button and return the first response immediately
%   showclear: if 0, hide clear button
%   pointsonly: if 1, return only the initial loc of each click, no paths
%
% Note that this code can be easily modified to take more arguments and
% use more involved GUI objects.
%
% invoked by r = goPrepResponse(r,varargin)
%
% r = goPrepResponse(r,3,[100 100 800 500],0,{'paths' 'Clear' 'OK'},{[.1 .3 .8 .6] [.1 .1 .3 .1] [.6 .1 .3 .1]},{imagedata [] []})
% r = goPrepResponse(r,3,[1921 433 1024 746],1,{'paths' 'Clear' 'OK'},{[0 0 1 1] [.025 .9 .075 .075] [.9 .9 .075 .075]},{imagedata [] []},{'showok',0,'showclear',0})


% these should be the defaults:
% numbuttons = 3;
% buttontitles = {'paths' 'Clear' 'OK'};
% buttonpos = {[0 0 1 1] [.025 .9 .075 .075] [.9 .9 .075 .075]};

if nargin<8
    ytick = [];
    if nargin<7
        xtick = [];
        if nargin<4 
            nocursor = 0;
            if nargin < 3
                if nargin < 2
                    options = [];
                else
                    options = numbuttons; % called with r and options
                end
            end
        end
    end
end

if isempty(nocursor)
    nocursor = 0;
end
    
if iscell(xtick)
    imagedata = xtick;
    options = ytick;
    xtick = [];
    ytick = [];
else
    imagedata = [];
end



respParams = get(r,'params');
if ~isfield(respParams,'guifig') || isempty(respParams.guifig) || ~ismember(respParams.guifig,findobj('name','Select response'))
    % make a GUI figure
    f = figure('name','Select response','menubar','none','resize','off');
    if nargin<3 || isempty(windowpos)
        
        windowpos = get(f,'Position');
        windowpos(4) = windowpos(3)./4;
    end
    
    set(f,'Position',windowpos);
    
    if nocursor
        set(f,'pointer','custom','pointershapecdata',nan(16),'pointershapehotspot',[9 9]);
    end
    
    respParams.guifig = f;
    respParams.guibuttons = [];
    r = set(r,'params',respParams); % newfig - replace the buttons
    
    % these are the "callback" type functions. The plan is to have a
    % 'WindowButtonDownFcn' defined when the GUI is active. This initiates
    % response collection and activates 'WindowButtonMotionFcn' and
    % 'WindowButtonUpFcn' during finger drag.
    
     set(f,'WindowButtonMotionFcn', '','WindowButtonDownFcn', @startDrag,'WindowButtonUpFcn', '','UserData',{[]});
%    set(f,'WindowButtonMotionFcn', '','WindowButtonDownFcn', '','WindowButtonUpFcn', '','UserData',{[]});
    
    
    
    % user data is a cell array with {[handles to line objects] [path1] [path2]}
    
else
    f = get(r,'params','guifig');
     set(f,'WindowButtonMotionFcn', '','WindowButtonDownFcn', @startDrag,'WindowButtonUpFcn', '','UserData',{[]});
%    set(f,'WindowButtonMotionFcn', '','WindowButtonDownFcn', '','WindowButtonUpFcn', '','UserData',{[]});
    for i = 1:length(respParams.guibuttons)
        % reset the titles and positions if necessary
        if exist('buttonpos')
            
            set(respParams.guibuttons(i),'position',buttonpos{i});
        end
        ht = get(respParams.guibuttons(i),'title');
        if exist('buttontitles')
            set(ht,'string',buttontitles{i});
        end
    end
end

figure(f);

respParams = get(r,'params');

%if ~isfield(respParams,'guibuttons') || length(respParams.guibuttons) ~= numbuttons

if ~isfield(respParams,'guibuttons') || isempty(respParams.guibuttons) %|| length(respParams.guibuttons) ~= numbuttons
    
    % buttons don't exist yet. Make them.
    
    % calculate positions for the buttons in the GUI
    marginLR = .05; % margin at Left and Right
    marginTB = .2; % margin at Top and Bottom
    marginBB = .2; % margin Between Buttons
    butwidth = 1-2.*marginLR;
    butleft  = marginLR;
    butheight = (1-(2.*marginTB)-(numbuttons-1).*marginBB)./numbuttons;
    butbottom = linspace(1-marginTB-butheight,marginTB,numbuttons);
    
    buttontags = {'paths' 'clear' 'ok'};
    
    % make the buttons
    for i = 1:numbuttons
        % BUtton 1 is really just an empty axes.
        %     i = 1;
        u(i) = axes('units','normalized','tag',buttontags{i},'UserData',struct('drawing',0,'l',[],'x',[],'y',[]));
        
        if ~isempty(imagedata) && ~isempty(imagedata{i})
            hi(i) = image([0 1],[1 0],imagedata{i},'Parent',u(i));
            set(u(i),'ydir','normal','tag',buttontags{i})
        end
        
        if nargin>=6 && length(buttonpos)==numbuttons
            set(u(i),'position',buttonpos{i});
        else
            set(u(i),'position',[butleft butbottom(i) butwidth butheight]);
        end
        
        %         axis([0 1 0 1]);
        set(u(i),'xtick',xtick,'xticklabel',[],'Ytick',ytick,'yticklabel',[],'box','on');
        if nargin>=5 && length(buttontitles)==numbuttons
            if i>1  % but a title on buttons 1 and 2
                title(u(i),buttontitles{i},'position',[.5 .5],'horizontalalignment','center','verticalalignment','middle');
            else
                title(u(i),buttontitles{i},'visible','off'); % hidden title for paths window
            end
        end
        
        
        
    end
    
    r = set(r,'params','guibuttons',u);
else
    u = get(r,'params','guibuttons');
end

% some additional optoins
    for iopt = 1:2:length(options)
        var = options{iopt}; % e.g., 'showclear'
        val = options{iopt+1}; % e.g., 0
        switch(options{iopt})
            case 'showclear' % hide the clear button
                if val, set(u(2), 'visible','on');
                else set(u(2),'visible','off');
                end
            case 'showok' % hide the ok button (and collect a single response)
                if val, set(u(3), 'visible','on');
                else set(u(3),'visible','off');
                end
            case 'pointsonly' % do not return paths, only the initial click
                if val
                set(gcf,'WindowButtonDownFcn',@singleClick);
                else
                set(gcf,'WindowButtonDownFcn',@startDrag);
                end
        end
    end


% Response collection: don't do this. 
% % set(f,'UserData',[]);
% tic % set a timer
% 
% % loop to wait for subject response
% mydata = {};
% while ~isstruct(mydata) % when cell array, just temporary. Final will be a struct with field 'paths'
%     drawnow;
%     mydata = get(f,'UserData'); % callbacks will fill f user data
%     pause(0.1);
% end
% set(f,'UserData',[]);
% 
% 
% r = set(r,'respData',mydata);  % set the data and return

%%% ------------------------------------------------------------------
%%% window and button callbacks
%%% ------------------------------------------------------------------
function mouseMove (object, eventdata)
% switch get(get(gca,'title'),'string')
%     case 'paths'
%         C = get (gca, 'CurrentPoint');
%         ud = get(gca,'UserData'); % current path...
%         ud.x(end+1) = C(1,1);  % extend the path
%         ud.y(end+1) = C(1,2);
%         if ud.drawing
%             set(ud.l,'xdata',ud.x,'ydata',ud.y,'color','r');
%         end
%         set(gca,'UserData',ud,'xlim',[0 1],'ylim',[0 1]);
%         %         title(gca, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')' num2str(ud.drawing)]);
%     otherwise
%         fprintf('Surprise, surprise! How did you get here?\n');
% end

function singleClick (object, eventdata)
% foo = get(gca,'tag');
% switch foo
%     case 'paths'
%         C = get (gca, 'CurrentPoint');
%         set(gca,'UserData',struct('drawing',1,'l',line(C(1,1),C(1,2),'linewidth',20),'x',C(1,1),'y',C(1,2))); % clear the contents; start drawing
%   
% %         set(gcf,'windowButtonMotionFcn',@mouseMove);
%          set(gcf,'windowButtonUpFcn',@stopDrag);
%         
%     case 'clear' % clear
%          foo = get(gcf,'UserData');
%          delete(foo{1}); % hide the line objects
%          % reset the stored paths:
%          set(gcf,'UserData',{[]});
%                  
%     case 'ok' % ok
%         returnresponses;
% 
% end

function startDrag (object, eventdata)
% this is defined in touchPathGetResponse, not here. 

% foo = get(get(gca,'title'),'string');
% switch foo
%     case 'paths'
%         C = get (gca, 'CurrentPoint');
%         set(gca,'UserData',struct('drawing',1,'l',line(C(1,1),C(1,2),'linewidth',20),'x',C(1,1),'y',C(1,2))); % clear the contents; start drawing
%         
%         % ah, this next is tricksy (learnt from doc windowButtonMotionFcn).
%         % don't set the motion fcn until we have a mouse down. This avoids
%         % calling the func all the time when the cursor is flying around.
%         % Also we can avoid running it in the other axes this way.
%         set(gcf,'windowButtonMotionFcn',@mouseMove);
%         set(gcf,'windowButtonUpFcn',@stopDrag);
%         
%     case 'Clear' % clear
%         foo = get(gcf,'UserData');
%         delete(foo{1}); % hide the line objects
%         % reset the stored paths:
%         set(gcf,'UserData',{[]});
%         
%     case 'OK' % ok
%         returnresponses;
% end

function returnresponses
%         % get the stored paths
%         paths = get(gcf,'UserData');
%         % hide the line objects
%         delete(paths{1});
%         % return just the path data
%         respdata.paths = paths(2:end);
%         % since we're done, disable clicking in the window now
%         set(gcf,'UserData',respdata,'windowButtonDownFcn','');

function stopDrag (object, eventdata)

% switch get(get(gca,'title'),'string')
%     case 'paths'
%         
%         ud = get(gca,'UserData');
%         
%         if length(ud.x)==1 % single click
%             l(1) = line(ud.x(1),ud.y(1),'marker','o','markersize',40,'markerfacecolor',[.7 .7 .7],'color','r','linestyle','none'); % draw the origin
%             
%         else
%             l(1) = line(ud.x,ud.y,'color','r','linewidth',20); % draw the contents
%             l(2) = line(ud.x(1),ud.y(1),'marker','o','markersize',40,'markerfacecolor',[.7 .7 .7],'color','r','linestyle','none'); % draw the origin
%             % caluclate the direction
%             foox = diff(ud.x); fooy = diff(ud.y);
%             dx = foox(end); dy = fooy(end);
%             if abs(dx) > abs(dy) % left or right
%                 if dx>=0, mark = '>'; else mark = '<'; end
%             else
%                 if dy>=0, mark = '^'; else mark = 'v'; end
%             end
%             
%             l(3) = line(ud.x(end),ud.y(end),'marker',mark,'markersize',40,'markerfacecolor',[.7 .7 .7],'color','r','linestyle','none'); % draw the destination
%         end
%         
%         mylines = get(gcf,'UserData'); % save the lines
%         mylines{1} = [mylines{1} l]; % these are the handles to permanently stored line objects
%         mylines{end+1} = [ud.x; ud.y];
%         set(gcf,'UserData',mylines);
%         
%         delete(ud.l); % get rid of the temporary line object
%         set(gca,'UserData',struct('drawing',0,'l',[],'x',[],'y',[])); % clear the contents; stop drawing
%         
%         set(gcf,'windowButtonMotionFcn','');
%         set(gcf,'windowButtonUpFcn','');
%         
%         % In some cases we want to return after we collect a single
%         % response. In those cases, the 'OK' button should not be visible
%         theaxes = get(gcf,'children');
%         i = find(strcmp(get(theaxes,'tag'),'ok'));
%         if ~strcmp(get(theaxes(i),'visible'),'on')
%             % No "OK" button; return first response
%             drawnow;
%             pause(0.5); % let subject see the endpoints?
%             returnresponses;
%         end
% 
%     otherwise
%         fprintf('Surprise, surprise! How did you get here?\n'); % should not happen except in the paths window
%         
% end

