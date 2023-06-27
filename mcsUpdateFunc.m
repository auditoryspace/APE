function t = mcsUpdateFunc(t,curtrial,response,target)
%
% function t = mcsUpdateFunc(t,curTrial,response,target)
%
% edited by CS on 4/5/10 to add curtrial input
% previously: % function t = mcsUpdateFunc(t,response,target)
%
% update the mcs tracker <t>. In this case, store the target and response
% in t.trialdata, then increment t.status.currenttrial so that the next call to
% t.nextValueFunc will give the next value stim value
%
% and t.status should have fields:
% status.currenttrial = 0;
% status.done = 0;

% added 4/5/10, CS
if nargin == 3 % hack. old call to mcsUpdateFunc didn't have curtrial in position 2
    %shift the arguments around
    target = response; 
    response = curtrial;
    curtrial = [];
end

if isempty(curtrial)
    % here's how it shows up in LevittUpdateFunc:
    %iTrial = length(get(t,'trialdata','currentvalue')); % update trial at the end
    
    % but here's how we do it here?
    curtrial = get(t,'status','currentTrial');
end

%curtrial = get(t,'status','currentTrial');

%% update trialdata
td = get(t,'trialdata',curtrial);
td.response = response;
td.target = target;
td.correct = response == target;
t = set(t,'trialdata',curtrial,td);

%% update confusion matrix
s = get(t,'status');
if isfield(s,'confusion') && ~mod(target,1) && ~mod(response,1)
    cm = s.confusion;
    % check for undersized confusion matrix (means we haven't seen this combo
    % before).
    if size(cm,1) < target || size(cm,2) < response
        cm(target,response) = 0;
    end
    cm(target,response) = cm(target,response)+1;
    t = set(t,'status','confusion',cm);
end

%% check if it's done
if curtrial == length(get(t,'trialdata'))
    t = set(t,'status','done',1);
else
    t = set(t,'status','currentTrial',get(t,'status','currentTrial')+1);
end
