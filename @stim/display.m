function display(s)

fprintf('\n%s = \n\nStim object [%d x %d]\n\n',inputname(1),size(s,1),size(s,2));
display(struct(s));