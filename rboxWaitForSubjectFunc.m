function r = rboxWaitForSubjectFunc(r,p)
%function r = rboxWaitForSubjectFunc(r,p)
%
% wait for subject by lighting LED and waiting for button press. 

soft_trig(p,10);
fprintf('Press any button when ready\n');
set_tag_val(p,'LED1',1); % indicate ready

buttpress = 0; % wait
while ~buttpress
    buttpress = get_tag_val(p,'Button_Press');
end

set_tag_val(p,'LED1',0); % indicate started
fprintf('Subject started...\n'); % alert experimenter

