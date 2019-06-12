function r = guiTellDoneFunc(r,varargin)
%function r = guiTellDoneFunc(r,pos)
%
% Put a button on the screen and wait for subject to click it. 
%
% Provide window position as an optional second argument [10/5/09]
%
% Provide  text as optional third argument [6/11/10]
%
% Provide text position in normalized units [l b w h] as 4th arg
% [6/11/10]
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

f = figure('name','Run finished','menubar','none');
    if nargin>ipos && isnumeric(varargin{ipos})
        pos = varargin{ipos};
    else
        pos = get(f,'Position');
        pos(4) = pos(3)./4;
    end

    set(f,'Position',pos);
    
    % what to display?
    if nargin>itext && ischar(varargin{itext})
        buttontitle = varargin{itext};
    else
        buttontitle = 'All done';
    end
    fprintf('%s.\n',buttontitle);


    % compute position for text display
    if nargin>ibuttonpos && ~isempty(varargin{ibuttonpos});
        buttonpos = varargin{ibuttonpos};
    else

        marginLR = .05; % margin at Left and Right
        marginTB = .12; % margin at Top and Bottom
        butwidth = (1-(2.*marginLR));
        butleft = marginLR;
        butheight = 1-2.*marginTB;
        butbottom = marginTB;
        buttonpos = [butleft butbottom butwidth butheight];
    end
    

    u = uicontrol('style','text','units','normalized',...
        'position',buttonpos,...
        'fontunits','normalized','fontsize',0.8,...
        'tag',num2str(i),'string',buttontitle);

% loop to wait for subject response
tic
while toc<4
    drawnow
    pause(1)
end
try
    close(f);    % close the fig
end
