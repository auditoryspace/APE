function r = headtrackWaitForSubjectFunc(r,p)
%function r = headtrackWaitForSubjectFunc(r,p)
%
% wait for subject by lighting LED and waiting for button press. 

soft_trig(p,10);
fprintf('Press button when ready, to boresight and begin\n');
set_tag_val(p,'LED1',1); % indicate ready
set_tag_val(p,'LED2',1); % indicate ready
set_tag_val(p,'LED3',1); % indicate ready
set_tag_val(p,'LED4',1); % indicate ready
set_tag_val(p,'LED5',1); % indicate ready

buttpress = 0; % wait
while ~buttpress
    buttpress = get_tag_val(p,'Button_Press');
end

set_tag_val(p,'LED1',0); % indicate started
set_tag_val(p,'LED2',0); % indicate started
set_tag_val(p,'LED3',0); % indicate started
set_tag_val(p,'LED4',0); % indicate started
set_tag_val(p,'LED5',0); % indicate started
soft_trig(p,2); % send trigger to boresight head tracker

fprintf('Subject started...\n'); % alert experimenter

