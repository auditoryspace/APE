function [val t] = mcsReportFunc(t,varargin)
% function [val t] = mcsReportFunc(t,varargin)
% 
% report the results of using tracker <t>. In this case, complain. I
% suggest overriding with a better function, such as:
%
% group trials by stimulus parameters. average the responses. fit a
% psychometric and estimate threshold
% 
% or:
%
% compute mutual information from confusion matrices

if nargin == 1
    outfid = 1;
else
    outfid = varargin{1}; % print table to a file
end

% 09/05/2017: borrowed code from mcsPlotFunc.m to generate a table of psychometric functionsby default:

tracked_vars = get(t,'params','tracked_vars');

varnames = fieldnames(tracked_vars);

        % CS 06/11/17 - modified to find plottable variables
        % automatically
        
        % first, figure out how many values there are for each tracked var:
        for i = 1:length(varnames)
            mylens(i) = length(getfield(tracked_vars,varnames{i}));
        end
        [foo isort] = sort(mylens,'descend');  
        % the longest should be the x-axis of our plot
        i_plotX = isort(1);
        % the second longest should be the parameters
        % updated CS 9/28/2020 to handle case with only one tracked
        % parameter
        if length(isort) == 1
            i_plotparam = [];
        else
            i_plotparam = isort(2);
        end
        correct = get(t,'trialdata','correct');
        ind_vars = get(t,'trialdata',varnames{i_plotX});
        ind_vars = ind_vars(1:length(correct)); % only plot the trials we have run.
        ind_vals = tracked_vars.(varnames{i_plotX});
        
        if isempty(i_plotparam)
            param_vars = ones(length(get(t,'trialdata')),1);
            param_vars = param_vars(1:length(correct));
            param_vals = 1;
        else
            param_vars = get(t,'trialdata',varnames{i_plotparam});
            param_vars = param_vars(1:length(correct));
            param_vals = tracked_vars.(varnames{i_plotparam});
        end
        
        pc = nan(length(ind_vals),length(param_vals));
        sd = nan(length(ind_vals),length(param_vals));
        se = nan(length(ind_vals),length(param_vals));
        n = nan(length(ind_vals),length(param_vals));

        meanpc = nan(length(ind_vals),1);
        meansd = nan(length(ind_vals),1);
        meanse = nan(length(ind_vals),1);

        for i = 1:length(ind_vals)
            for j = 1:length(param_vals)
                icor = correct(find(ind_vars==ind_vals(i) & param_vars==param_vals(j)));
                if ~isempty(icor)
                    pc(i,j) = mean(icor);
                    sd(i,j) = std(icor);
                    se(i,j) = std(icor)/sqrt(length(icor));
                    n(i,j) = length(icor);
                end
            end
            % mean across param vals
            icor = correct(find(ind_vars==ind_vals(i)));
            if ~isempty(icor)
                meanpc(i,1) = mean(icor);
                meansd(i,1) = std(icor);
                meanse(i,1) = std(icor)/sqrt(length(icor));
            end
 
        end
        
        fprintf(outfid,'PC:\t');
        for j = 1:length(param_vals);
        fprintf(outfid,'%s\t',num2str(param_vals(j)));
        end
        fprintf(outfid,'\n');
        for i = 1:length(ind_vals);
            fprintf(outfid,'%s\t',num2str(ind_vals(i)));
            for j = 1:length(param_vals);
                fprintf(outfid,'%s\t',num2str(pc(i,j)));
            end
        fprintf(outfid,'\n');
        end            
            
val = pc;

% fprintf('MCS Tracker Report: not implemented\n');