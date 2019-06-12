function h = ballplot_area_sum(m,totalarea,filled,vals,usediameter)
% h = ballplot_area_sum(m,totalarea,filled,vals,usediameter)
%
% m is a matrix. plot values as filled circles in a grid. 
%
% area of circle proportional to ratio of element to column-wise sum 
%    (ie across stimuli in a confusion matrix)
%
%
% the following args are optional. leave off or [] for default value.
%
% totalarea [40] gives the total area in each column (max possible circle area)
% filled [0]  flag. fill with black if 1, with gray if 0.
% vals [1:size(m,1)] are the values of choices (for xtick label)
% usediameter [0] flag. if 1, make diameter, not area, prop to value
%
% make sure that columns are stimuli, rows are response to get proper
% normalization

if nargin< 5 || isempty(usediameter)
    usediameter = 0;
end

if nargin< 4 || isempty(vals)
    xvals = 1:size(m,2);
    yvals = 1:size(m,1);
elseif iscell(vals) % for non-square matrices, vals should have two elements
    xvals = vals{1};
    yvals = vals{2};
else
    xvals = vals;
    yvals = vals;
end

if nargin<3 || isempty(filled)
    filled = 0;
end

if nargin<2 || isempty(totalarea)
    totalarea = 40;
end

maxm = max(max(m));
minm = min(min(m));

if minm<0
    m = m-minm;
end

% normalize by sum in each column
m = m./repmat(sum(m,1),size(m,1),1);


if ~usediameter
    % transform from area to radius
    m = 2.*sqrt(m./pi);
end

%m = m./maxm; % should range 0 to 1 now.
m = round(m.*totalarea); % sizes up to maxsize pt 

 if ~ishold
     cla;
 end
 
 hi = [];
 
for i = 1:size(m,1)
    for j = 1:size(m,2)
        if m(i,j) > 0
            % CS 5 27 2010 : swapped i and j subscripts to vals on next two
            % lines
            if filled 
                hi(end+1) = line(xvals(j),yvals(i),0,'LineStyle','none','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',m(i,j));   
 %               hi(end+1) = line(j,i,0,'LineStyle','none','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',m(i,j));   
            else
                hi(end+1) = line(xvals(j),yvals(i),0,'LineStyle','none','Marker','o','MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','k','MarkerSize',m(i,j));   
 %              hi(end+1) = line(j,i,0,'LineStyle','none','Marker','o','MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','k','MarkerSize',m(i,j));   
            end
        end
    end
end

% xt = get(gca,'XTick'); xt = xt(find(xt>0 & xt<=length(vals))); set(gca,'XTickLabel',vals(xt));
% yt = get(gca,'YTick'); yt = yt(find(yt>0 & yt<=length(vals))); set(gca,'YTickLabel',vals(yt));

set(gca,'Box','on');
axis([min(xvals)-1 max(xvals)+1 min(yvals)-1 max(yvals)+1]);

if nargout > 0, h = hi; end