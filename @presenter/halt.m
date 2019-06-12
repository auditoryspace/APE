function p = halt(p)

% find device types with circuits loaded
circuit_devs = fieldnames(p.circuit_files);

% halt each one
for iDevType = 1:length(circuit_devs)
    dev_type = circuit_devs{iDevType}; % eg 'RP2'
    for iDev = 1:length(p.devices.(dev_type))
        
        switch dev_type
            case {'local_audio'}
                % do nothing
            case {'Dante' 'PsychPortAudio'}
                dev = p.devices.(dev_type)(iDev);
                ud = get(dev,'UserData');
                ph = ud.PsychPortAudioDevice;
                PsychPortAudio('Close',ph);
            otherwise  %TDT
                invoke(p.devices.(dev_type)(iDev),'Halt');
                p.status.(dev_type)(iDev) = invoke(p.devices.(dev_type)(iDev),'GetStatus');
        end
    end
end
