function [val, t] = goReport(t,varargin)
% function [val, t] = goReport(t,varargin)
%
% goReport evaluates <r.reportFunc>. Do not edit this file.
% Instead, write a reportFunc function, and set t.reportFunc to
% the handle to that function

[val t] = feval(t.reportFunc,t,varargin{:});
