function ex = goPrepTrial(ex,varargin)
% function ex = goPrepTrial(ex,varargin)
%
% goPrepTrial evaluates <ex.prepTrialFunc>. Do not edit this file.
% Instead, write a prepTrialFunc function, and set ex.prepTrialFunc to
% the handle to that function

ex = feval(ex.prepTrialFunc,ex,varargin{:});
