function varargout = get(p,varargin)

slotname = varargin{1};

switch slotname
    case 'status'
        status = [];
        circuit_devs = fieldnames(p.circuit_files);
        for iDevType = 1:length(circuit_devs)
            dev_type = circuit_devs{iDevType}; % eg 'RP2'
            for iDev = 1:length(p.devices.(dev_type))
                switch dev_type
                    case {'local_audio'}
                        mystat = 7; % assume local audio is always working
                    case {'Dante'}
                        ud = get(p.devices.(dev_type)(iDev),'UserData');
                        ph = ud.PsychPortAudioDevice;
                        mystat = PsychPortAudio(ph,'GetStatus'); % this will be PTB struct format
                        if nargin > 2
                            mystat = mystat.(varargin{2}); % return slot of status struct
                        end
                    otherwise
                        mystat = invoke(p.devices.(dev_type)(iDev),'GetStatus');
                end
                p.status.(dev_type)(iDev) = mystat;
                status = [status mystat];
            end
        end
        %
        %         dev_types = fieldnames(p.status);
        %         for idevtype = 1:length(dev_types)
        %             status = [status p.status.(dev_types{idevtype})];
        %         end
        
        if isstruct(status) || any(diff(status))
            varargout = {status}; % multiple samp rates
        else
            varargout = {status(1)}; % all devices share samprate
        end
        
    case 'partags'
        partags = {};
        dev_types = fieldnames(p.circuit_files);
        for i = 1:length(dev_types)
            dev_type = dev_types{i};
            num_devs = length(p.devices.(dev_type));
            for dev_number = 1:num_devs
                partags = {partags{:} p.partags.(dev_type){dev_number}{:}};
            end
        end
        varargout = {partags};
    case 'add_commands'
        varargout = {p.add_commands};
    case 'samprate'
        samprates = [];
        dev_types = fieldnames(p.samprate);
        for idevtype = 1:length(dev_types)
            samprates = [samprates p.samprate.(dev_types{idevtype})];
        end
        if ~any(diff(samprates))
            varargout = {samprates(1)}; % all devices share samprate
        else
            varargout = {samprates}; % multiple samp rates
        end
    otherwise
        error(sprintf('invalid slotname: %s',slotname));
end