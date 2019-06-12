function ex = experiment(varargin)
% function ex = experiment(varargin)
% constructor object for experiment
%
% An experiment object is is responsible for initializing and storing
% experimental parameters and control objects (stim, responder, and
% presenter objects). Experiment objects define methods for initialization,
% trial preparation, trial execution, trial reporting, data saving, data
% plotting, data analysis, as well as pausing and resuming of experimental
% runs

switch nargin
    case 0 % create an empty presenter object
        
        %%% data 
        ex.params = struct; % experiment parameters such as intervals, trials, etc
 
        ex.status = struct('currentTrial',0,'paused',0,'done',0); % status structure. add fields as necessary
        
        ex.stimparams = struct; % stimulus parameters (separated from ex.params only for tidiness)
                
        ex.presenter = []; % a presenter object (wrapper for TDT)
        ex.responder = []; % a responder object (interacts with subjects)
        ex.tracker = []; % array of tracker objects for Levitt, etc methods
 
        ex.stim_templates = []; % struct of stim objects
                            % e.g. stim_templates.stimA defines stim type A,
        ex.trial_stim = []; % array of stim objects (usually one per interval) modified for each trial
       
        ex.trialdata = struct; % array of structures containing trial-variable params & data

        
        %%% functions
        ex.initFunc = @defaultExInitFunc; % get ready to go. instantiate objects, preload trialdata, etc
        ex.prepTrialFunc  = @defaultExPrepTrialFunc; % figure out what the next trial should be
        ex.presentTrialFunc = @defaultExPresentTrialFunc; % execute a trial
        ex.reportTrialFunc = @defaultExReportTrialFunc; % report on a trial to a GUI or command line, etc
        ex.pauseFunc = @defaultExPauseFunc; % anything that needs to happen when a run is temporarily halted
        ex.resumeFunc = @defaultExResumeFunc; % resume run after pause
        ex.saveDataFunc = @defaultExSaveDataFunc; % save data
        ex.wrapupFunc = @defaultExWrapupFunc; % plot, analyze, etc.
        
        ex = class(ex,'experiment');
    otherwise % has been called with name,value pairs. Use these to fill slots

        ex = experiment; % first create a blank one.

        for iArg = 1:2:nargin % fill the slots
            slotname = varargin{iArg};
            slotval = varargin{iArg+1};

            if ~isfield(struct(ex),slotname)
                fprintf('\n%s is not a valid presenter slot name.',slotname);
            else
                eval(sprintf('ex.%s = slotval;',slotname));
            end
        end
end
