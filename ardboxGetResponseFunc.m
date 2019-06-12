function r = ardboxGetResponseFunc(r,varargin)
%function r = ardboxGetResponseFunc(r)
%function r = ardboxGetResponseFunc(r,'readonly')
%
% This is a getResponse function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, <r> interacts with arduion object (stored in r.params.s)
% to read from the TDT RBOX. 
%
% After this call, r.respdata will have the following structure:
%   button: (button pressed by subject)
%   reactiontime: (time from function call to button press, in seconds)
%
% including 'readonly' as argument 2 will simply return the first button
%   pressed since last reset (using ardboxPrepResponseFunc)
% otherwise, latch will be reset and call to this function will wait for
% the next button press
%
% invoked by r = goGetResponse(r,varargin)

% get the device
s = get(r,'params','device');

% set it up if missing
% if isempty(instrfind) || ~exist(get(s,'port')) || ~strcmp(get(s,'status'),'open')
if isempty(instrfind) || ~strcmp(get(s,'status'),'open')
      fprintf('Resetting ardbox\n');
  s = ardboxInitFunc;
    r = set(r,'params','device',s);
    fprintf(s,'LR\n');
    pause(1);
end




if nargin>1 & strcmp(varargin{1},'readonly')
    fprintf(s,'RB\n'); % ask for the first button pressed since last reset
else 
    fprintf(s,'LB\n'); % reset the button box and ask for response
end

tic % set a timer

response = fgetl(s); % wait for a button press
 rt = toc;  % record "reaction time"
 
mydata.button = str2num(response);  % which button was pressed

mydata.reactiontime = rt;


r = set(r,'respData',mydata);