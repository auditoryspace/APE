function [val t] = levittReportFunc(t,varargin)
% function [val t] = levittReportFunc(t,varargin)
% 
% report the results of using tracker <t>. In this case, average the values
% of the last <t.params.avglastreversals> reversals

params = get(t,'params');
if ~isfield(params,'logstep')
    params.logstep = 0;
end
    
    numrev = get(t,'params','avglastreversals');
    reversal = get(t,'trialdata','reversal');
    correct = get(t,'trialdata','correct');
    currentvalue = get(t,'trialdata','currentvalue');
    
    if isfield(params,'tracked_vars')
        fn = fieldnames(params.tracked_vars);
        rev_vals = [currentvalue(find(reversal)).(fn{1})];
    else
                rev_vals = currentvalue(find(reversal));
    end
    
if length(rev_vals) < numrev
    val = nan;
elseif params.logstep % use the geometric mean if we did log steps
    val = geomean(rev_vals(end-(numrev-1):end));
else
    val = mean(rev_vals(end-(numrev-1):end));
end