function ex = defaultExReportTrialFunc(ex,varargin)
% ex = defaultExReportTrialFunc(ex,varargin)
%
% This is the default reportTrialFunc for experiment objects. It's job is
% to update the experimenter's display with relevant info (stim & response
% parameters, performance estimates, whatever). You might want to print
% some information in the MATLAB console, or plot a figure, or update a
% GUI. Here, just print the current trial number on the command line.

fprintf('Trial %d\n',get(ex,'status','currentTrial'));