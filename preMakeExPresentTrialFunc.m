function ex = preMakePresentTrialFunc(ex)
% ex = preMakePresentTrialFunc(ex)
%
% This is the default ex.presentTrialFunc, called by ex.goPresentTrial. 
%
% In this case, modified to call makestim for all intervals prior to 
%   playing them. This is useful if the makestim function is slow, and 
%   particularly, if the target synthesis is slower than the reference,
%   as this can potentially provide a cue to the target interval. 
%
% presentTrialFuncs should handle presenting a trial's worth of stimuli, etc. to
% the subject. By default, this function loops through the stim objects
% contained in ex.trial_stim, calls goPresent on each, pausing
% ex.params.isi between. You should modify it to do what you want.
%
% Trial preparation (that is, preparing ex.trial_stim) is handled by
% ex.prepTrialFunc. Response monitoring, feedback presentation should be
% handled to separate calls to appriopriate responder methods in your main
% loop, but could be incorporated here if you wish. Updating of
% the experimenter's display (GUI, graph, and/or console line) should be
% handled by ex.reportTrialFunc. 
%
% (c) 2023 G. Christopher Stecker for Auditory Space, LLC

params = get(ex,'params');
trial_stim = get(ex,'trial_stim');
p = get(ex,'presenter');


for iInterval = 1:length(trial_stim)
        % first, make the next stim. You might do this outside of the loop,
        % depending on how your s.makeStimFunc works.
        trial_stim(iInterval) = goMakeStim(trial_stim(iInterval)); 
%         fprintf('Int %d: %d samples\n',iInterval,length(get(trial_stim(iInterval),'tags','SigL')));
end

t1 = tic;
for iInterval = 1:length(trial_stim)

        % next prepare the stim for presentation. Normally, this means
        % uploading tags to the presenter object p
        goReady(trial_stim(iInterval),p); 
        
        
        % the next step is to actually present the stim, but first wait for
        % the isi to finish
        while toc(t1) < params.isi % wait for ISI to finish
            drawnow
        end

        % do it!
        goPresent(trial_stim(iInterval),p); % tell TDT to go
        
        
        % now, be sure to wait until the stim is done playing...here we use
        % the checkBusyFunc defined by stim objects.
        while(goCheckBusy(trial_stim(iInterval),p))
            drawnow;
        end
        
                % reset the isi timer
        t1 = tic;

%         pause(0.01); % extra pause because timing doesn't work as it should?
end
    
