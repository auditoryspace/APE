function r = knobBoxAWaitForSubjectFunc(r,p)
%function r = knobBoxAWaitForSubjectFunc(r,p)
%
% wait for subject to press a button. 

fprintf('Press any button when ready\n');

buttpress = 0; % wait
while ~buttpress
    buttpress = get_tag_val(p,'Button_Press');
end

fprintf('Subject started...\n'); % alert experimenter

