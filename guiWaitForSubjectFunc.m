function r = guiWaitForSubjectFunc(r,varargin)
%function r = guiWaitForSubjectFunc(r,pos,buttontitle,buttonpos)
%
% Put a button on the screen and wait for subject to click it. 
%
% Provide window position as an optional second argument [10/5/09]
%
% Provide button text as optional third argument [10/12/09]
%
% Provide button position in normalized units [l b w h] as 4th arg [6/11/10]
%
% Fixed to handle case where 2nd arg is a presenter object (to allow
% identical syntax to rbox type responder)
%
% invoked by r = goWaitForSubject(r,varargin)

if nargin>1 && isa(varargin{1},'presenter') % if the second arg is a presenter (for compatibility with rbox syntax),
    ipos = 2; % then other args are shifted one place. CS 4/12/12
    itext = 3;
    ibuttonpos = 4;
else
    ipos = 1;
    itext = 2;
    ibuttonpos = 3;
end

f = figure('name','Click to start','MenuBar','none');

    if nargin>ipos && ~isempty(varargin{ipos}) && isnumeric(varargin{ipos})
        pos = varargin{ipos};
    else
        pos = get(f,'Position');
        pos(4) = pos(3)./4;
    end

    set(f,'Position',pos);

    if nargin>itext && ischar(varargin{itext})
        buttonstring = varargin{itext};
    else
        buttonstring = 'Start';
    end

% p = get(f,'Position');
%     p(4) = p(3)./4;
%     set(f,'Position',p);
    if nargin>ibuttonpos && ~isempty(varargin{ibuttonpos});
        buttonpos = varargin{ibuttonpos};
    else

        marginLR = .05; % margin at Left and Right
        marginTB = .12; % margin at Top and Bottom
        butwidth = (1-(2.*marginLR));
        butleft = marginLR;
        butheight = 1-2.*marginTB;
        butbottom = marginTB;

        buttonpos = [butleft butbottom butwidth butheight]
    end

       u = uicontrol('units','normalized','callback',@clickme,...
            'position',buttonpos,...
            'fontunits','normalized','fontsize',0.8,...
            'tag',num2str(i),'string',buttonstring);

% loop to wait for subject response
tic
mydata = [];
while isempty(mydata)
    drawnow;
    mydata = get(f,'UserData'); % clickme will fill f's UserData
end
close(f);    % close the fig

%%% ------------------------------------------------------------------
%%% clickme - the button callback
%%% ------------------------------------------------------------------
function mydata = clickme(varargin)

rt = toc; % measure reaction time
mydata.button = str2num(get(gcbo,'tag')); % figure out what button was pressed
mydata.reactiontime = rt;
set(get(gcbo,'Parent'),'UserData',mydata); % store the data in the GUI figure