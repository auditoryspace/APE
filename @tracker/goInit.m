function t = goInit(t,varargin)
% function t = goInit(t,varargin)
%
% goInit evaluates <r.initFunc>. Do not edit this file.
% Instead, write a initFunc function, and set t.initFunc to
% the handle to that function

t = feval(t.initFunc,t,varargin{:});

