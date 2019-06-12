function done = checkDone(ex)
% done = checkDone(ex)
%
% Check to see if the experiment is done. Return 1 if done, 0 if not

if ~isempty(ex.tracker)
    done = checkDone(ex.tracker);
else
    done = get(ex,'status','done');
end
