function s = defaultPresentFunc(s,p)
% function s = defaultPresentFunc(s,p)
%
% default presentFunc for stim objects. presentFunc is responsible for
% triggering the presenter object appropriately. In this case, it simply
% issues soft trigger 1. readyFunc should prepared the presenter object
% before this call is made
%
% invoked by s = goPresentFunct(s,p);

soft_trig(p,1);
