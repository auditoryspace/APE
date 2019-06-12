function r = ardboxPrepResponseFunc(r)

% prepare to read a a response. In this case, set latch mode to 1 (latched)
%   and reset the button latch on Arduino RBOX reader

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

fprintf(s,'LM 1\n');
        
fprintf(s,'LR\n');
