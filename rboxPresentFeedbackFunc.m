function r = rboxPresentFeedbackFunc(r,p,correct)
%function r = rboxPresentFeedbackFunc(r,p,correct)
%
% This is the default presentFeedback function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, the LED corresponding to the correct response will light 
% for on second.

%
% invoked by r = goPresentFeedback(r,varargin)

% respbut = get(r,'respdata','button');
% respLED = sprintf('LED%d',respbut);
correctLED = sprintf('LED%d',correct);

% set_tag_val(p,respLED,1);
% pause(1);
% set_tag_val(p,respLED,0);
% pause(0.3);
set_tag_val(p,correctLED,1);
pause(1);
set_tag_val(p,correctLED,0);

