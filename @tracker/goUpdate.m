function t = goUpdate(t,varargin)
% function t = goUpdate(t,varargin)
%
% goUpdate evaluates <r.updateFunc>. Do not edit this file.
% Instead, write a updateFunc function, and set t.updateFunc to
% the handle to that function

t = feval(t.updateFunc,t,varargin{:});

