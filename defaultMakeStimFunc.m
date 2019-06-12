function s = defaultMakeStimFunc(s)
% function tags = defaultMakeStimFunc(params)
%
% default makeStimFunc for stim objects. makeStimFunc must take a stim with 
% a params structure(s.params) as input and return the stim with the 
% tags structure (s.tags) updated accordingly. In this case, 
%
% s.tags = s.params;
%
% invoked by s = goMakeStimFunc(s);

s = set(s,'tags',get(s,'params'));