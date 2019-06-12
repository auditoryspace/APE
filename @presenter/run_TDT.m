function p = run_TDT(p)

% find device types with circuits loaded
circuit_devs = fieldnames(p.circuit_files);

% halt each one
for iDevType = 1:length(circuit_devs)
    dev_type = circuit_devs{iDevType}; % eg 'RP2'
    for iDev = 1:length(p.devices.(dev_type))
        invoke(p.devices.(dev_type)(iDev),'Run');
        p.status.(dev_type)(iDev) = invoke(p.devices.(dev_type)(iDev),'GetStatus');
    end
end
