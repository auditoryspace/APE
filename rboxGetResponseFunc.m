function r = rboxGetResponseFunc(r,p,varargin)
%function r = rboxGetResponseFunc(r,p)
%function r = rboxGetResponseFunc(r,p,'reset')
%
% This is a getResponse function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, <r> interacts with presenter object <p> to read from the 
% TDT RBOX. After this call, r.respdata will have the following structure:
%   button: (button pressed by subject)
%   reactiontime: (time from function call to button press, in seconds)
%
% including 'reset' as argument 3 will cause response reset before
% collection
%
% invoked by r = goGetResponse(r,varargin)

tic % set a timer

if nargin>2 & strcmp(varargin{1},'reset')
    soft_trig(p,10); % reset the button box
end

while ~get_tag_val(p,'Button_Press') % wait for a button press
end

rt = toc; % record reaction time
which_but = get_tag_val(p,'Which_But'); % which button was pressed

mydata.button = log2(which_but)+1; % assemble result
mydata.reactiontime = rt;


r = set(r,'respData',mydata);