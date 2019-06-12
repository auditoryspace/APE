function s = goPresent(s,p,presentFunc)
%function s = goPresent(s,p,presentFunc)

if nargin > 2
    s.presentFunc = presentFunc;
end

s = feval(s.presentFunc,s,p);

    