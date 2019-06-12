function r = touchpathPresentFeedbackFunc(r,correct,type,x,y)
%function r = touchpathPresentFeedbackFunc(r,correct,type,x,y)
%
% This is the default presentFeedback function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, present a red or green border, patch, or star over the touchpath GUI
%
% Required: correct (1 or 0)
%
% Optional args:
% type can be 'patch' 'border' or 'star' [default is 'border']
%    will be centered on 0.5,0.5 and cover screen unless x,y specified
%
% invoked by r = goPresentFeedback(r,varargin)
%
%

if nargin<4
    x = []; y = [];
    if nargin < 3
        type = 'border';
    end
end

if correct
    buttoncolor = 'g';
else
    buttoncolor = 'r';
end

% make a GUI figure
f = get(r,'params','guifig');
u = get(r,'params','guibuttons');

figure(f);
axes(u(1));

switch type
    case 'patch'
        if isempty(x), x = [0 1 1 0 0]; end
        if isempty(y), y = [0 0 1 1 0]; end
        l = patch(x,y,buttoncolor);
    case 'border'
        scale = .99;
        if isempty(x), x = [0 1 1 0 0].*scale+.5*(1-scale); end
        if isempty(y), y = [0 0 1 1 0].*scale+.5*(1-scale); end
        l = line(x,y,'linewidth',10,'color',buttoncolor);
    case 'star'
        if isempty(x), x = 0.5; end
        if isempty(y), y = 0.5; end
        l = line(x,y,'marker','p','markerfacecolor',buttoncolor,'markeredgecolor',buttoncolor,'markersize',80);
    otherwise
        warning(['Unknown feedback type: ' type]);
end

    pause(1);
    delete(l);
