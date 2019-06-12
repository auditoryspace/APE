function ex = goResume(ex,varargin)
% function ex = goResume(ex,varargin)
%
% goResume evaluates <ex.resumeFunc>. Do not edit this file.
% Instead, write a resumeFunc function, and set ex.resumeFunc to
% the handle to that function

ex = feval(ex.resumeFunc,ex,varargin{:});