function busy = defaultCheckBusyFunc(s,p)
% function busy = defaultCheckBusyFunc(s,p)
%
% default checkBusyFunc for stim objects. checkBusyFunc should return true
% if the stim is currently busy (playing) and false if done. Implementations 
% may vary. One possibility is to record the time that goPresent was called
% and compare the current time to that record and the stim duration (both
% should be maintained somewhere like s.params). Another possibility is to
% include a "busy" parameter tag on the TDT patch, and query that. A third
% possibility is simply to pause an appropriate amount of time within
% s.presentFunc and then not bother with checkBusyFunc.
%
% In this case, if "busy" or "Busy" is a partag of <p>, check it. Otherwise return 0.
%
% invoked by s = goCheckBusy(s,p);

foo = [];
try
    foo = get_tag_val(p,'Busy');
catch
    try 
        foo = get_tag_val(p,'busy');
    end
end

if ~isempty(foo)
    busy = foo;
else
    busy = 0;
end