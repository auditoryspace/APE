function r = ardboxTellDoneFunc(r,p)
%function r = ardboxTellDoneFunc(r,p)
%
% 
% alert the operator and subject that we're done.

% alert the operator first
fprintf('All done.\n');
% beep;


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


light_sequence = [4 255 200; ...
                    3 255 200; ...
                    2 255 200; ...
                    1 255 200; ...
                    2 255 200; ...
                    3 255 200];

                % Flash some lights to say "you're finished"
for i = 1:4
        for j = 1:size(light_sequence,1)
            theVals = light_sequence(j,:);
                         pause(0.16);
            cmd = ['SF' sprintf(' %d',light_sequence(j,:)) '\n'];
            fprintf(s,cmd);

        end
end

% light_sequence = [  1 0 0 0; 0 1 0 0; 1 0 1 0; 0 1 0 1; ...
%                     1 0 1 1; 0 1 1 1; 1 1 1 1; 0 1 1 1; ...
%                     0 0 1 1; 0 0 0 1; 0 0 0 0];
% 
%                 % Flash some lights to say "you're finished"
% for i = 1:2
%         for j = 1:size(light_sequence,1)
%             theVals = light_sequence(j,:);
%             cmd = ['SA' sprintf(' %d',floor(theVals.*255)) '\n'];
%             fprintf(s,cmd);
%             pause(1);
%         end
% end

% alert the operator....BUT HOW???
% for i = 1:2, beep; pause(0.8); end


% Note that using pause() and serial commands is very slow
% a better approach would be to define a flashing display in 
% the arduino sketch