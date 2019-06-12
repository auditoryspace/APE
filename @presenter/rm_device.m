function p = rm_device(p,dev_type,dev_number)
%  p = rm_device(p,dev_type,dev_number)
%
%  Remove a device from the presenter object
%
%  Example: p = rm_device(p,'RP2',1) % removes 1st RP2 from presenter

% Basically, this works by going through all the presenter slots, looking
% for slots that define this dev_type. For PA5, this will be only the
% devices field, but for RP2, RM2, etc all fields will have info on this
% device

% these are regular arrays. just find the right element and delete it
myfields = {'devices' 'samprate' 'status'};
for ifield = 1:length(myfields)
    if isfield(p.(myfields{ifield}),dev_type)
        p.(myfields{ifield}).(dev_type)(dev_number) = [];
    end
end

% these are cell arrays...slightly different syntax
myfields = {'circuit_files' 'partags'};
for ifield = 1:length(myfields)
    if isfield(p.(myfields{ifield}),dev_type)
        p.(myfields{ifield}).(dev_type){dev_number} = '';
    end
end
