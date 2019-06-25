function t = levittInitFunc(t,varargin)
%function t = levittInitFunc(t,varargin)
%
% this is the init func for levitt trackers. 
% t.params should have the following fields:
%
%   nup
%   ndown
% start
% step
% stepreversals
% avgreversals
% floor
% ceiling
% 
% optionally include t.params.tracked_vars, a struct similar to MCS trackers
%     it should have only one field, named for the tracked variable
%    
% if tracked_vars is included, you may also included t.params.fixed_vars
%     a struct with format similar to MCS' tracked_vars
%     (each field defines a variable and its value the value)
%     This is useful when interleaved tracks are used for different values of
%     one or more stimulus parameters
%    
% e.g.:
%     t.params = struct('ndown',2,'nup',1,'start',100,'step',[10 2 1],...
%         'stepreversals',[2 2 8],'avgreversals',8,'floor',0,'ceiling',200,...
%         'tracked_vars',struct('delta_freq',100),...
%         'fixed_vars',struct('base_freq',1000,'level',-20));
%     


% load in the tracker parameters
params = get(t,'params');

% initialize the tracker status
status = struct('totalreversals',0,'numreversals',0,'ncorrect',0,'nwrong',0,'goingup',0,'goingdown',0);
status.steps = params.step;
status.step = status.steps(1);
status.stepreversals = params.stepreversals;
status.done = 0;

t = set(t,'status',status);



if isfield(params,'tracked_vars')
    fn = fieldnames(params.tracked_vars);
    if length(fn) > 1
        error('multiple tracked variables defined for levitt tracker');
    else
        curval = struct(fn{1},params.start);
    end
    
    % fixed_vars lets multiple tracks handle different values of another
    % parameter (i.e. a non-tracked parameter)
    if isfield(params,'fixed_vars')
       fn = fieldnames(params.fixed_vars);
       for ifield = 1:length(fn)
           curval.(fn{ifield}) = params.fixed_vars.(fn{ifield});
       end
    end
else
    curval = params.start;
end


% initialize the tracker trialdata
trialdata = struct('currentvalue',curval,'nextvalue',[],'response',[],'target',[],'correct',[],'reversal',[],'increase',[],'decrease',[]);

t = set(t,'trialdata',trialdata);