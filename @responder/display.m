function display(r)

fprintf('\n%s = \n\nResponder object [%d x %d]\n\n',inputname(1),size(r,1),size(r,2));
display(struct(r));