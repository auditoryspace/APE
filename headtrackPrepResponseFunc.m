function r = headtrackPrepResponseFunc(r,p)

% prepare to read a a response. In this case, send a software trigger to
% TDT to reset the button latches

soft_trig(p,10);
