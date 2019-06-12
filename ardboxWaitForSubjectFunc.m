function r = ardboxWaitForSubjectFunc(r)
%function r = ardboxWaitForSubjectFunc(r)
%
% wait for subject by lighting LED and waiting for button press. 

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



pause(0.5);
fprintf(s,'SA 255 255 255 255\n'); % light all the lights
pause(0.5);
fprintf('Press any button when ready\n');

fprintf(s,'LB\n'); % reset and wait for any button press

theLine = fgetl(s); % wait for button to return

fprintf(s,'SA 0 0 0 0\n');

fprintf('Subject started...\n'); % alert experimenter

