function r = rboxPrepResponseFunc(r,p)

% prepare to read a a response. In this case, send a software trigger to
% TDT to reset the RBOX reader

soft_trig(p,10);
