function p = set(p,slotname,slotval)

switch slotname
otherwise
    error(sprintf('invalid slotname: %s',slotname));
end