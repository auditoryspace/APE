function r = ardboxPresentFeedbackFunc(r,target)
%function r = ardboxPresentFeedbackFunc(r,target)
%
% This is the default presentFeedback function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, the LED corresponding to the target response will light 
% for one second.
%
% invoked by r = goPresentFeedback(r,varargin)


% get the device
s = get(r,'params','device');


% set it up if missing
% if isempty(instrfind) || ~exist(get(s,'port')) || ~strcmp(get(s,'status'),'open')
if isempty(instrfind) || ~strcmp(get(s,'status'),'open')
    s = ardboxInitFunc;
    r = set(r,'params','device',s);
    fprintf(s,'LR\n');
    pause(1);
end

% Don't use this yet, but in the future, color the LED based on
%   correct response or not...
respbut = get(r,'respData','button');
if respbut == target
    buttoncolor = 'g';
else
    buttoncolor = 'r';
end

% turn it on for one second
cmd = sprintf('SF %d 255 1000\n',target);
fprintf(s,cmd);
