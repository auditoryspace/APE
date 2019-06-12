function [val t] = levittNextValueFunc(t)


nextvalue = get(t,'trialdata','nextvalue');

if isempty(nextvalue) % true if we haven't updated trial yet (i.e. before we do the trial)
    val = get(t,'trialdata','currentvalue');
    return
end
    
iTrial = length(nextvalue);
val = nextvalue(iTrial);

% basically, just copy the value from thistrial.nextvalue to
% nexttrial.currentvalue

t = set(t,'trialdata',iTrial+1,'currentvalue',val);
