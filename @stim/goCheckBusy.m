function s = goCheckBusy(s,p,presentFunc)
%function s = goCheckBusy(s,p,presentFunc)

if nargin > 2
    s.checkBusyFunc = checkBusyFunc;
end

s = feval(s.checkBusyFunc,s,p);

    