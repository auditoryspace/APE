function d = checkDone(t)

if length(t)== 1
    d = t.status.done;
else
    d = [checkDone(t(1)) checkDone(t(2:end))];
end