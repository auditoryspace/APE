function display(t)

fprintf('\n%s = \n\nTracker object [%d x %d]\n\n',inputname(1),size(t,1),size(t,2));
display(struct(t));