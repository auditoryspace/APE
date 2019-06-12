function ex = defaultExResume(ex,varargin)
% function ex = defaultExResume(ex,varargin)
%
% This is the default function to be called by goResume(ex). It sets 
% ex.status.paused to 0 and calls recreate(ex.presenter) to reconnect 
% to TDT (since the TDT may not have been connected continuously 
% during the pause period). 
%
% If you'd like different  behavior, write a new function that  
% does it, and use that (by setting ex.resumeFunc to that function's 
% handle) instead.

p = get(ex,'presenter');

if ~isempty(p)
    p = recreate(p);
end

ex = set(ex,'presenter',p);

ex = set(ex,'status','paused',0);
