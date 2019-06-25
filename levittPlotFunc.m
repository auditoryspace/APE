function theData = levittPlotFunc(t,varargin)
% theData = levittPlotFunc(t,varargin)
%
% plot a track

reversal = get(t,'trialdata','reversal');
correct = get(t,'trialdata','correct');
currentvalue = get(t,'trialdata','currentvalue');

params = get(t,'params');
if isfield(params,'tracked_vars')
    fn = fieldnames(params.tracked_vars);
    currentvalue = [currentvalue.(fn{1})];
end
        


irev = find(reversal);
icor = find(correct);
iwrong = find(~correct);

if length(irev) >= get(t,'params','avglastreversals')
    mythresh = goReport(t);
else
    mythresh = nan;
end

hp = plot(1:length(currentvalue),currentvalue,'k-',...
    icor,currentvalue(icor),'ks',...
    iwrong,currentvalue(iwrong),'k^',...
    irev,currentvalue(irev),'ro',...
    [1 length(currentvalue)],[1 1]*mythresh,'k--');

if checkDone(t)
    symbolcolor = [.7 .7 .7];
    set(hp(5),'LineStyle','-','LineWidth',2);
else
    symbolcolor = 'k';
end

if length(hp)
    set(hp(2),'MarkerFaceColor',symbolcolor);
    if length(hp) > 2
        set(hp(3),'MarkerFaceColor',symbolcolor);
        if length(hp) > 3
            set(hp(4),'MarkerSize',12,'LineWidth',2);
        end
    end
end

theData = [];