function ex = defaultExPauseFunc(ex,varargin)
% function ex = defaultExPauseFunc(ex,varargin)
%
% This is the default function to be called by goPause(ex). It simply sets
% ex.status.paused to 1. If you'd like something to happen when you pause your
% experiment, write a new function that does it, and use that (by setting
% ex.pauseFunc to that function's handle) instead.

ex = set(ex,'status','paused',1);