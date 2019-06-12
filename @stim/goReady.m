function s = goReady(s,p,readyFunc)
%function s = goReady(s,p,readyFunc)

if nargin > 2
    s.readyFunc = readyFunc;
end

s = feval(s.readyFunc,s,p);

    