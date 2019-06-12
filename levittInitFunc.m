function t = levittInitFunc(t,varargin)
%function t = levittInitFunc(t,varargin)
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


% initialize the tracker trialdata
trialdata = struct('currentvalue',params.start,'nextvalue',[],'response',[],'target',[],'correct',[],'reversal',[],'increase',[],'decrease',[]);

t = set(t,'trialdata',trialdata);