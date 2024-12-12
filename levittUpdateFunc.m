function t = levittUpdateFunc(t,iTrial,response,target)
%
% function t = levittUpdateFunc(t,iTrial,response,target)
%
% these parameters (or something similar) should already be defined in
% t.params:
%
% method = 'levitt'; % method of constant stimuli
% ndown = 3;
% nup = 1;
% start = 100;
% step = [5 2];
% logstep = 0; % steps are log10 of ratios
% stepreversals = [4 6];
% avglastreversals = 6;
%
% and t.status should have fields:
% numreversals = 0;
% ncorrect = 0;
% nwrong = 0;
% goingup = 0;
% goingdown = 0;

params = get(t,'params');
status = get(t,'status');
trialdata = get(t,'trialdata');

% XXX added 3/4/09 by CS, allow user to specify log steps. In this case,
% status.steps will be log units (base 10), and adjustments of the tracked
% parameter will be multiples (or divisions) of the base amount
if ~isfield(params,'logstep')
    params.logstep = 0;
end


if isempty(iTrial)
    iTrial = length(get(t,'trialdata','currentvalue')); % update trial at the end
end


% update the tracker
t = set(t,'trialdata',iTrial,'response',response);
t = set(t,'trialdata',iTrial,'target',target);
t = set(t,'trialdata',iTrial,'correct',response == target);


% by default, don't change
t = set(t,'trialdata',iTrial,'reversal',0);
t = set(t,'trialdata',iTrial,'increase',0);
t = set(t,'trialdata',iTrial,'decrease',0);

% decide whether to change.
if get(t,'trialdata',iTrial,'correct') % RIGHT
    status.nwrong = 0;
    status.ncorrect = status.ncorrect + 1;
    if status.ncorrect == params.ndown
        % make it harder...make the value go down
        t = set(t,'trialdata',iTrial,'decrease',1);
        if status.goingup
            t = set(t,'trialdata',iTrial,'reversal',1);
        end
        status.goingup = 0; status.goingdown = 1;
        status.ncorrect = 0;
    end
else % WRONG
    status.ncorrect = 0;
    status.nwrong = status.nwrong + 1;
    if status.nwrong == params.nup
        % make it easier..make the value go up
        t = set(t,'trialdata',iTrial,'increase',1);
        if status.goingdown
            t = set(t,'trialdata',iTrial,'reversal',1);
        end
        status.goingup = 1; status.goingdown = 0;
        status.nwrong = 0;
    end
end

% if reversal, update step size or quit
if get(t,'trialdata',iTrial,'reversal')
    status.numreversals = status.numreversals + 1;
    status.totalreversals = status.totalreversals + 1;
    if status.numreversals >= status.stepreversals(1)
        status.numreversals = status.numreversals - status.stepreversals(1);
        status.stepreversals = status.stepreversals(2:end);
        status.steps = status.steps(2:end);
        if isempty(status.steps)
            status.done = 1;
        else
            status.step = status.steps(1);
        end
    end
end

% CS 08/01/23 - do we need to keep this in status, or just count trialdata?
status.currentTrial = iTrial;

% if maxtrials is specified, check and quit if we've reached it
if isfield(params,'maxtrials') && iTrial >= params.maxtrials
    status.done = 1;
end


% compute the next value
curval = get(t,'trialdata',iTrial,'currentvalue');

% default is to keep the current value

if isfield(params,'tracked_vars')
    fn = fieldnames(params.tracked_vars);
    curvalstruct = curval;
    curval = curval.(fn{1}); % turn it into a scalar for adjustment
end

newval = curval;

if get(t,'trialdata',iTrial,'decrease')
    if params.logstep % use a logarithmic step
        newval = curval * 10^(-status.step);
    else % use a linear step
        newval = curval - status.step;
    end
elseif get(t,'trialdata',iTrial,'increase')
    if params.logstep % use a logarithmic step
        newval = curval * 10^(status.step);
    else % use a linear step
        newval = curval + status.step;
    end
end

if newval > params.ceiling
    warning('Track hit ceiling. Current val %.2f, step %.2f, floor %.2f',curval,status.step,params.ceiling);
    newval = params.ceiling;
elseif newval < params.floor
    warning('Track hit floor. Current val %.2f, step %.2f, floor %.2f',curval,status.step,params.floor);
    newval = params.floor;
end

% consider adding functionality here. if t.params defines 'tracked_vars',
% make newval a struct with matching fields (only one, presumably, is
% defined). This will force behavior similar to MCS type trackers and
% enable defaultExPrepTrialFunc to work in many cases.
if isfield(params,'tracked_vars')
    fn = fieldnames(params.tracked_vars);
    if length(fn) > 1
        error('multiple tracked variables defined for levitt tracker');
    else
        newvalstruct = curvalstruct;
        newvalstruct.(fn{1}) = newval;
        newval = newvalstruct;
        %         newval = struct(fn{1},newval);
    end
    
    % section below is commented out because fixed variables were instantiated
    % in the init func and should exist in curvalstruct. no need to put them in again here.
    %     % fixed_vars lets multiple tracks handle different values of another
    %     % parameter (i.e. a non-tracked parameter)
    %     if isfield(params,'fixed_vars')
    %        fn = fieldnames(params.fixed_vars);
    %        for ifield = 1:length(fn)
    %            newval.fn{ifield} = params.fixed_vars.(fn{ifield});
    %        end
    %     end
    
end

t = set(t,'trialdata',iTrial,'nextvalue',newval); % newval may be a scalar or a struct

t = set(t,'status',status);

