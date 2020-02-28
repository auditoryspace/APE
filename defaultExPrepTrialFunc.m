function ex = defaultExPrepTrialFunc(ex,varargin)
% function ex = defaultExPrepTrialFunc(ex,varargin)
%
% This is the default prepTrialFunc, that would be called by
% ex.goPrepTrial. Really, there isn't an obvious default behavior, so this
% doesn't do much. You should make a new function appropriate to your
% experiment. Look through the comments here for ideas about things that
% might need doing.
%
% The main goal is to fill ex.trial_stim so that ex.goPresentTrial does right

% You might want to bring in other arguments after <ex>. For example, trial
% number or tracker number could be decided in your main loop and fed to 
% this function as arguments, or they could be decided here. 

% Everything here is just meant to give an idea of what you might want to
% do and how you could do it. 

% What trial is this? 
trialNumber= get(ex,'status','currentTrial')+1;
ex = set(ex,'status','currentTrial',trialNumber);

params = get(ex,'params');
if isfield(params,'intervals')
    intervals = params.intervals;
else
    intervals = [];
end

if isfield(params,'method')
    method = params.method;
else
    method = [];
end

% choose which track(er) to update
trackers = get(ex,'tracker');
undone = find(~checkDone(trackers)); % select a tracker that's not done  CS 11/24/08
foo = randperm(length(undone));
foo = undone(foo); 
trackNumber = foo(1);
t = get(ex,'tracker',trackNumber);

% get new values for tracked parameters
[newval t] = goNextValue(t);
ex = set(ex,'tracker',trackNumber,t);

% compute roving for any roved parameters
if isfield(params,'rove') % added 10/28/08
     rovestruct = get(ex,'params','rove'); % which params to rove
    rovefields = fieldnames(rovestruct);
    for iField = 1:length(rovefields) % compute a value for each interval and each roving parameter
        switch length(rovestruct.(rovefields{iField}))
            case 1
                % This is the initial behavior (from CS 10/28/09). rovestruct has a
                % fields corresponding to stimulus params, and each field has a value which specifies
                % the roving range (uniform distribution)
                rove.(rovefields{iField}) = rovestruct.(rovefields{iField}).*(rand(1,length(intervals)).*2-1);
            otherwise
                % New behavior here (CS 4/5/12): if the rove value is an
                % array, these are the discrete values roving can take.
                % select one for each interval using randperm (note that
                % this guarantees a different value for each interval
                % NOTE ALSO that there must be more values than intervals
                if length(intervals)>length(rovestruct.(rovefields{iField}))
                    error(sprintf('There must be at least as many values for parameter %s roving as there are intervals.\n',...
                        rovefields{iField}));
                end
                
                foo = rovestruct.(rovefields{iField});
                foo = foo(randperm(length(foo)));
                rove.(rovefields{iField}) = foo(1:length(intervals));

        end
    end
end

% this is a dummy call that creates the trialdata struct for the upcoming
% trial
ex = set(ex,'trialdata',trialNumber,'target',0);

% start updating trialdata. <mytrialdata> is the trialdata struct for only
% this trial.
mytrialdata = get(ex,'trialdata',trialNumber);
if isfield(mytrialdata,'trackNumber')  % don't keep it around if we only have one track
    mytrialdata.trackNumber = trackNumber;
end


% perhaps choose the target interval...this example is based on my scheme,
% where ex.params.intervals will be '-XX-' or 'AXXA' or 'AXB'
intervals = get(ex,'params','intervals');
targints = find(intervals == 'X');

trial_intervals = intervals; % 'AXB'
stimtypes = intervals; stimtypes(targints) = []; % 'AB'

if isempty(stimtypes), stimtypes = '-'; end % this handles 'XX' (presume only one stim type)
% CS 08/25/09 changed prev line from stimtypes = 1 to stimtypes = '-' 

switch length(targints)
    case 1 % 'AXB' etc...chose a stim type for X randomly
        foo = randperm(length(stimtypes)); % [1 2]
        trial_intervals(targints) = stimtypes(foo(1)); % 'AXB'->'AAB', '-X'->'--'
        %targint = []; % doesn't make sense
        targint = targints; % CS 8/25/09
        mytrialdata.target = targint; % CS 4/5/10
    otherwise % 'AXXA' etc. choose targ interval from among the Xs. 
        foo = randperm(length(targints));
        targint = targints(foo(1));
        mytrialdata.target = targint;
        % Need to add code here for assigning stim types to 'X' intervals 
        % In this case, a goofy assumption: pick randomly from stimtypes
        % This will work for AXXA...what about AXXB or AXBXC? 
        for i = 1:length(targints)
            foo = randperm(length(stimtypes));
            trial_intervals(targints(i)) = stimtypes(foo(1));
        end
end


% populate ex.trial_stim
% default: stim for this trial is just the 1st template stim
for i = 1:length(trial_intervals)
    trial_stim(i) = get(ex,'stim_templates',trial_intervals(i)); % stim_templates.A, etc
    
    if isfield(params,'rove') % assign roving
        for iField = 1:length(rovefields) 
            thisrove = rove.(rovefields{iField}); % this holds all intervals
            trial_stim(i) = set(trial_stim(i),'params',rovefields{iField},thisrove(i)); 
        end
    end
    
    % CS 02/27/2020 ... need non-target intervals to have the same fixed
    % (non tracked) values as the target. This matters only for interleaved
    % trackers with different fixed values
    tp = get(t,'params');
    if isfield(tp,'fixed_vars') && ~isempty(tp.fixed_vars)
        names = fieldnames(tp.fixed_vars);
        for iname = 1:length(names) % make stim vals match newval vals
            trial_stim(i) = set(trial_stim(i),'params',names{iname},tp.fixed_vars.(names{iname}));
        end
        
    end
    

    if i == targint
        % do something here to differentiate the target...presumably, this
        % means setting its tracked parameter to <newval>
        
        % Here, I'm going to assume that tracker t implements the variable
        % 'tracked_vars' which will be a struct containing fields
        % corresponding to each tracked variable. In the case of mcs
        % trackers, <newval> will be a struct with matching fields. In the
        % case of levitt trackers, <newval> will be a single value, but
        % tracked_vars will have only one field...so they should match.
        %
        % On the other hand, we could (re)define a levitt tracker that
        % includes 'tracked_vars' as a tracker parameter, and have tracker.goNextValueFunc 
        % return a struct like MCS trackers do...
        
        % here, force numeric newval (old levitt tracker) to be struct
        % (behaves like MCS)
        if isnumeric(newval) % behaves like levitt tracker
            names = fieldnames(get(t,'params','tracked_vars'));
            newval = struct(names{1},newval); % assume newval refers to #1 tracked var
            %setfield(trial_stim(i),names{1},newval);
        end

        if isstruct(newval) % behaves like MCS tracker
           names = fieldnames(newval);
           for iname = 1:length(names) % make stim vals match newval vals
               mytrialdata.(names{iname}) = newval.(names{iname});
               trial_stim(i) = set(trial_stim(i),'params',names{iname},newval.(names{iname}));
           end
        else
           error('defaultExPrepTrialFunc cannot deal with your tracker object');
        end
        
    end
end

ex = set(ex,'trial_stim',trial_stim); 
ex = set(ex,'trialdata',trialNumber,mytrialdata);


