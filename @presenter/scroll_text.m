function scrolltext(p,atten_num,msg,rate)
%function scrolltext(p,atten_num,msg,rate)
%
% scroll a text message <msg> across one or more PA5 devices
%
% p: presenter object
% atten_num: PA5 device(s) to use
% msg: string to scroll
% rate: shifts per second. default = 4;
%
% atten_num can be a number (1) or array (1 2). Leave empty to use all
% defined PA5s.

if nargin < 4
    rate = 4;
end

if ~isfield(p.devices,'PA5') | isempty(p.devices.PA5)
    fprintf('%s\\n',msg);
    return;
end

if isempty(atten_num)
    atten_num = 1:length(p.devices.PA5);
end

if any(atten_num > length(p.devices.PA5))
    error('Requested attenuator number exceeds number of defined PA5 devices');
end

% want to add spaces to pad out the message for scrolling
padlength = 8.* length(atten_num);
spacepad = 32 .* ones(1,padlength);
padmsg = [spacepad msg spacepad];

% make a timer object for each step in the scrolling.
numevents = length(msg)+padlength+1;
j = 0;
for i = 1:numevents
    for ipa = 1:length(atten_num)
    j = j+1; 
%    msg_segment = padmsg((i+padlength+(ipa-1)*8):(i+padlength+7+(ipa-1)*8));
    msg_segment = padmsg((i+(ipa-1)*8):(i+7+(ipa-1)*8));
    t(j) = timer('TimerFcn',{@timercallback, p, atten_num(ipa), msg_segment},'StartDelay',i./rate);
    end
end
start(t);


% tkiller is a timer obj to delete all the timer objects
tkiller = timer('TimerFcn',{@timerkill,t},'StartDelay',i./rate+1);
tkiller.TimerFcn = {@timerkill,[t tkiller]}; % even deletes itself
start(tkiller);


function timercallback(obj,event,p,atten_num,string)
pa5_display(p,atten_num,string);

function timerkill(obj,event,timers)
warning off  % don't let it complain about deleting itself
delete(timers);
warning on