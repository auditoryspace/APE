function s = goMakeStim(s,varargin)
%function s = goMakeStim(s,makeStimFunc)

for i = 1:length(s)
    s = feval(s(i).makeStimFunc,s(i),varargin{:});
end