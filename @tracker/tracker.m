function t = tracker(varargin) 
% t = tracker(varargin)
%
% constructor stim for tracker object
%
% Tracker objects are responsible for determining parameter values for new
% trials. Each tracker object monitors a single parameter and may or may
% not be updated on every trial. Experiment objects contain a field
% <tracker> that should be an array of trackers. Multiple trackers might
% independently track the same parameter, might track different parameters
% in multiple-judgment tasks, or be related to one another in some other
% way. In any case, the coordination of tracker behavior occurs at the
% experiment level, so each tracker only needs to know about its own
% parameter, history, etc. 

if nargin == 0 % create an empty tracker object
    t.type = ''; % an informative label
    t.params = struct; % tracker-type-specific parameters (nup, reversals, etc)
    t.status = struct; % current status of the tracker
    t.trialdata = struct; % similar to experiment.trialdata, an array of 
        % structures carrying trial-varying information. In this case, however,
        % trialdata will include data only for trials on which this tracker
        % is updated, and only for parameters this tracker needs access to.

    t.initFunc = @defaultTrackerInitFunc; % function called by goInit(t);
    t.updateFunc = @defaultTrackerUpdateFunc; % function called by goUpdate(t);
    t.nextValueFunc = @defaultTrackerNextValueFunc; % function to return next tracked value
    t.plotFunc = @defaultTrackerPlotFunc; % function to plot the track
    t.reportFunc = @defaultTrackerReportFunc; % function to analyze & report
    
    t = class(t,'tracker');

else % has been called with name,value pairs. Use these to fill slots
    if strcmp(class(varargin{1}),'tracker') % modify an existing stim
        t = varargin{1};
        varargstart = 2;
    else % or make a new one
        t = tracker;
        varargstart = 1;
    end
    
    % fill the slots
    for iArg = varargstart:2:nargin 
        slotname = varargin{iArg};
        slotval = varargin{iArg+1};

        if ~isfield(struct(t),slotname)
            fprintf('\n%s is not a valid stim slot name.',slotname);
        else
            eval(sprintf('t.%s = slotval;',slotname));
        end
        if strcmp(slotname,'type')
            t = default_type(t,slotval);
        end
        
    end
end

%%%------------------------
%%% default_type: set up function handles for one of several default
%%%     tracker types
%%%------------------------

function t = default_type(t,mytype)
switch mytype
    case 'mcs'
            t.initFunc = @mcsInitFunc; % function called by goInit(t);
            t.updateFunc = @mcsUpdateFunc; % function called by goUpdate(t);
            t.nextValueFunc = @mcsNextValueFunc; % function to return next tracked value
            t.plotFunc = @mcsPlotFunc; % function to plot the track
            t.reportFunc = @mcsReportFunc; % function to analyze & report
    case 'levitt'
            t.initFunc = @levittInitFunc; % function called by goInit(t);
            t.updateFunc = @levittUpdateFunc; % function called by goUpdate(t);
            t.nextValueFunc = @levittNextValueFunc; % function to return next tracked value
            t.plotFunc = @levittPlotFunc; % function to plot the track
            t.reportFunc = @levittReportFunc; % function to analyze & report
    otherwise
end


