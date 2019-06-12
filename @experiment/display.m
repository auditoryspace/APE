function display(ex)

fprintf('\n%s = \n\nExperiment object [%d x %d]\n\n',inputname(1),size(ex,1),size(ex,2));
display(struct(ex));