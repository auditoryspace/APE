function [val t] = mcsNextValueFunc(t)
% function [val t] = mcsNextValueFunc(t)
%
% return the next stim value, according to mcs tracker <t>
%
% val will be a struct with fields matching t.params.tracked_vars

curtrial = get(t,'status','currentTrial');
val = get(t,'trialdata',curtrial);

val = rmfield(val,'response');
val = rmfield(val,'target');
val = rmfield(val,'correct');
