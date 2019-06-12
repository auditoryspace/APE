function theData = mcsPlotFunc(t,plot_type,varargin)
% theData = mcsPlotFunc(t,plot_type,varargin)
%
% plot a track. this is mcs, so maybe plot something like a psychometric
% function, or override to plot a confusion matrix?
%
% definitely override with something that groups the different variables
%
% I'm leaving this partially implemented. Feel free to add plot types to
% this default function, if you write generally useful ones. Otherwise, for
% specific plotting, use this for ideas and override with something
% appropriate to your experiment.
%
% CS 5/22/18 - added option to give arguments to indicate which parameters
% to plot against. e.g. goPlot(t,'psychometric','intensity','frequency') 
% will plot a psychometric func against intensity for each frequency 

tracked_vars = get(t,'params','tracked_vars');

varnames = fieldnames(tracked_vars);

if nargin<2
    plot_type = 'psychometric';
end

switch plot_type
    
    case 'scatter'
        % CS 07/03/17 - modified to find plottable variables
        % automatically
        
        % first, figure out how many values there are for each tracked var:
        for i = 1:length(varnames)
            mylens(i) = length(getfield(tracked_vars,varnames{i}));
        end
        [foo isort] = sort(mylens,'descend');
        
        if nargin > 2 && strcmp(varargin{1},'flip')
            % flipped behavior: the second longest should be the x-axis of our plot
            i_plotX = isort(2);
            % the longest should be the parameters
            i_plotparam = isort(1);
        else % default behavior
            i_plotX = []; i_plotparam = [];
            
            if nargin > 2
            % maybe we were given the tracked_vars to plot against.
            i_plotX = find(strcmp(varargin{1},fieldnames(tracked_vars)));
            
            if nargin > 3
                i_plotparam = find(strcmp(varargin{2},fieldnames(tracked_vars)));
            end
            end
            
            if isempty(i_plotX)
                % the longest should be the x-axis of our plot
                i_plotX = isort(1);
            end
            if isempty(i_plotparam)
                % the second longest should be the parameters
                i_plotparam = isort(2);
            end
        end
        
        correct = get(t,'trialdata','correct');
        ind_vars = get(t,'trialdata',varnames{i_plotX});
        ind_vars = ind_vars(1:length(correct)); % only plot the trials we have run.
        ind_vals = tracked_vars.(varnames{i_plotX});
        
        %         param_vars = get(t,'trialdata',varnames{i_plotparam});
        %         param_vars = param_vars(1:length(correct));
        %         param_vals = tracked_vars.(varnames{i_plotparam});
        %
        
        ind_vars = get(t,'trialdata',varnames{i_plotX});
        response = get(t,'trialdata','response');
        if length(varnames) == 1 % one variable. just plot it
            plot(ind_vars(1:length(response)),response,'o');
        else
            cat_vars = get(t,'trialdata',varnames{i_plotparam}); % use variable 2 for category
            cats = unique(cat_vars);
            mysym = 'o+sd*x<>^v';
            mycol = 'brgkbrgkbr';
            cla; hold on;
            for ivar = 1:length(cats)
                incat = find(cat_vars==cats(ivar));
                incat(incat>length(response)) = [];
                if ~isempty(incat)
                    plot(ind_vars(incat),response(incat),[mycol(ivar) mysym(ivar)]);
                end
            end
            hold off
        end
        xlabel(varnames{i_plotX});
        ylabel('Response');
        theData = [ind_vars(1:length(response)) response];
        
    case 'means'
        % not implemented
    case 'psychometric'
        
        % CS 06/11/17 - modified to find plottable variables
        % automatically
        
        % CS 01/19/18 - modified to allow extra arg 'flip' to swap first
        % and second longest variables
        
        % first, figure out how many values there are for each tracked var:
        for i = 1:length(varnames)
            mylens(i) = length(getfield(tracked_vars,varnames{i}));
        end
        [foo isort] = sort(mylens,'descend');
        
        if nargin == 1 % case added 10/2/2018. Why missing?
            % the  longest should be the x-axis of our plot
            i_plotX = isort(1);
            % the second longest should be the parameters
            i_plotparam = isort(2);
        
        elseif nargin > 2 && strcmp(varargin{1},'flip')
            
            % the second longest should be the x-axis of our plot
            i_plotX = isort(2);
            % the longest should be the parameters
            i_plotparam = isort(1);
        else  % maybe we were given the tracked_vars to plot against.
           i_plotX = []; i_plotparam = [];
            
           if nargin > 2
               i_plotX = find(strcmp(varargin{1},fieldnames(tracked_vars)));
               
               if nargin > 3
                   i_plotparam = find(strcmp(varargin{2},fieldnames(tracked_vars)));
               end
           end
           
            if isempty(i_plotX)
                % the longest should be the x-axis of our plot
                i_plotX = isort(1);
            end
            if isempty(i_plotparam)
                % the second longest should be the parameters
                i_plotparam = isort(2);
            end
        end
        
        correct = get(t,'trialdata','correct');
        ind_vars = get(t,'trialdata',varnames{i_plotX});
        ind_vars = ind_vars(1:length(correct)); % only plot the trials we have run.
        ind_vals = tracked_vars.(varnames{i_plotX});
        
        param_vars = get(t,'trialdata',varnames{i_plotparam});
        param_vars = param_vars(1:length(correct));
        param_vals = tracked_vars.(varnames{i_plotparam});
        
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
        plot(repmat(ind_vals',1,size(pc,2)),pc);
        hold on;
        errorbar(ind_vals,meanpc,meanse,'color','k','linewidth',2);
        hold off;
        xlabel(varnames{i_plotX});
        legnames = num2str(param_vals(:)); legnames(end+1,1:9) = 'mean ± se';
        legend(legnames,'Location','SouthEast');
        title(sprintf('Plotting by %s for each %s',varnames{i_plotX},varnames{i_plotparam}));
        ylabel('Percent Correct');
        
        theData = [ind_vars correct];
        
    case 'confusion'  % implemented 01/19/18 by CS
        response = get(t,'trialdata','response');
        target = get(t,'trialdata','target');
        
        if nargin>2 % pass in the number of alternatives
            myprop = zeros(varargin{1});
        end
        
        ut = unique(target)';
        ur = unique(response)';
        if isnumeric(ut)
            for i = 1:length(ut)
                for j = 1:length(ur)
                    myprop(ut(i),ur(j)) = sum(target==ut(i) & response==ur(j));
                end
            end
        else
            % myprop are proportions
            for i = 1:length(ut) % this works even if targs, responses are cells of nonnumeric
                for j = 1:length(ur)
                    myprop(i,j) = sum(target==ut(i) & response==ur(j));
                end
            end
        end
        
        ballplot(myprop');
        xlabel('Target'); ylabel('Response')
        
        theData = myprop;
        
end