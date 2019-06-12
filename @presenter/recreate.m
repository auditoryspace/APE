function new_p = recreate(p)
% function new_p = recreate(p)
%
% Presenter objects remember the commands used to add devices to them and
% this function uses that memory to regenerate a presenter object from
% scratch. This is especially useful if <p> has been loaded from storage on
% disk and therefore not currently in communication with TDT devices.
% Recreate replaces <p> with a new presenter object, adding devices (and
% thus connecting to TDT) so that the new <p> matches the old <p>.

ac = get(p,'add_commands');
new_p = presenter;
for i = 1:length(ac)
    new_p = add_device(new_p,ac{i}{:});
end
