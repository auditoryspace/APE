function p = add_device(p,dev_type,dev_interface,dev_circuit,dev_samprate)
% function p = add_device(p,dev_type,dev_interface,dev_circuit,dev_samprate)
%
% Add a device to presenter object <p>. This function serves as a wrapper
% to all the connection, circuit loading, etc calls to TDT. 
%
% dev_type: device type. 'ZBUS', 'RP2', 'PA5', 'RM1' etc
% dev_interface: 'GB' 'USB'
% dev_circuit: for RP devices, load this circuit file (.rcx or .rco)
% dev_samprate: for RP devices, run at this sampling rate (nominal, in Hz)
%       can be 6000, 12000, 25000, 50000, 100000, or 200000
%
% special note: dev_type 'local_audio' (dev_interface []) can be used to specify local audio
%
% CS 9/8/2015: New device type 'Dante' for multichannel presentations. 
%   3rd arg should be a struct with fields: 
%       numtotalchans: how many playback channels to instantiate (64, 72?)
%       PBchans: array of playback chans [57 9] to send our audio to
%       gains: array of amplitude scalars for calibrating loudspeakers
%       delays: array of ms delay for calibrating loudspeakers
%       recchans: record chans (array of which channel numbers to record): [1 2]
%       recsamps: length of recording buffer, in samples.
%       blocking: blocking playback or not? (1 or 0)
%
%Example:
%
% p = presenter;
% p = add_device(p,'ZBUS','GB');
% p = add_device(p,'RP2','GB','simple_tone.rcx',50000);
% p = add_device(p,'PA5','GB');
% p = add_device(p,'PA5','GB');
% p = add_device(p,'Dante',64,16,48000);  % NO NO
% p = add_device(p,'Dante',struct('numtotalchans',64,'pbchans',[63 64 1 2],'recchans',[1 2],'recsamps',


% later functions will use dev_samprate so make sure it's defined
if nargin<5
    dev_samprate = [];
    if nargin<4
        dev_circuit = '';
    end
end

if ~isfield(p.devices,dev_type) % this is the first device of this type to be added
    dev_number = 1;
else
    dev_number = length(getfield(p.devices,dev_type)) + 1;
end

switch dev_type
    case {'local_audio'} % add a device for local audio
        if isempty(dev_samprate)
            dev_samprate = 48000; % changed from 44100 (CS 2/4/2016)
        end
        % this is a bit of a hack, but similar to the RPco.x actxcontrols,
        % we'll use a uicontrol for the local dev. Then we can store stuff
        % (audio) in the uicontrol's userdata field. 
        dev = uicontrol('position',[0 0 1 1],'visible','off');
        dev_interface = 'local_audio'; 
        dev_circuit = 'local_audio';
        success = 1;
        p.samprate.(dev_type)(dev_number) = dev_samprate;                
        p.circuit_files.(dev_type){dev_number} = 'local_audio';

        p.partags.(dev_type){dev_number} = {'SigSamps' 'SigL' 'SigR'};
        
        set(dev,'UserData',struct('SigSamps',[],'SigL',[],'SigR',[]));
        
    case {'Dante'} % add a (probably multichannel) Dante device (audio over ethernet)
        args = dev_interface; 
        
        if isempty(dev_samprate)
            dev_samprate = 48000;
        end
        
        % same hack as for localaudio, above
        % we'll use a uicontrol for the local dev. Then we can store stuff
        % (audio) in the uicontrol's userdata field. 
        dev = uicontrol('position',[0 0 1 1],'visible','off');
        success = 1;
        p.samprate.(dev_type)(dev_number) = dev_samprate;                
        p.circuit_files.(dev_type){dev_number} = 'Dante';

        % note difference here. Tags are called MCsig, not separate tags for SigL and SigR
        p.partags.(dev_type){dev_number} = {'NumTotalChans' 'PBChans' 'gains' 'delays' 'PBSamps' 'PBSig' 'RecChans' 'RecSamps' 'RecSig' 'Blocking'};
        
        
        d = PsychPortAudio('GetDevices');
        %i = strmatch('Aggregate Device',{d.DeviceName}); nchan = 4; % multiple sound cards aggregated in MacOS
        i = strmatch('Focusrite RedNet PCIe',{d.DeviceName}); % 64-512 channels of Dante via PCI
        if isempty(i)
            i = strmatch('Dante Virtual Soundcard',{d.DeviceName}); % up to 64 channels of Dante via DVS
        end
        
        DevID = d(i).DeviceIndex;
        
        % open device with 4 channels at 48000
        fprintf('Opening %s device %d (%s), using %d of %d output channels and %d of %d input channels\n',d(i).HostAudioAPIName,DevID,d(i).DeviceName,...
            args.numtotalchans,d(i).NrOutputChannels,length(args.recchans),d(i).NrInputChannels);
        
        % PsychPortAudio('Open',<devid>,<mode>,<reqlatencyclass>,<samprate>,<channels>,<buffersize>,<suggestedlatency>,<selectchans>,<specialflags>)
        % mode 1 = playback only, 2 = record, 3 = both
        % reqlatenyclass: 0 don't care; 1 try for low but stay reliable; 2 take
        %   sound card; 3 same as 2 but more aggressive; 4 fail if device can't
        %   meet requirements
        
        ph = PsychPortAudio('Open',DevID,3,1,48000,[args.numtotalchans length(args.recchans)],[],0.015); % 0.015 for latency necessary to keep it rolling

        % create a dummy / silent signal and load into the playback buffer:
        silentsig = zeros(args.numtotalchans,args.recsamps); % match the rec buffer length for now...?
        PsychPortAudio('FillBuffer',ph,silentsig);
        % read the rec buffer for the very first time. This initializes it.
        PsychPortAudio('GetAudioData', ph, args.recsamps, 2, 2);  % XXX the 2 and 2 should be args.recsamps I think? 
        
        % store the handle and the tag data to the UIcontrol
        set(dev,'UserData',struct('PsychPortAudioDevice',ph,...
            'NumTotalChans',args.numtotalchans,...
            'PBChans',args.pbchans,...
            'gains',args.gains,...
            'delays',args.delays,...
            'PBSamps',[],...
            'PBSig',[],...
            'RecChans',args.recchans,...
            'RecSamps',args.recsamps,...
            'RecSig',[],...
            'Blocking',args.blocking));
       
    case {'PsychPortAudio'}
        % not implemented yet, but this would be a more general version of
        % the Dante interface. Could be used in place of localaudio for 2-channel stuff. 
        % Any advantages to that? 
        
    case {'ZBUS'} % add the zBus device
        dev = actxcontrol('zBUS.x',[0 0 0 0]);
        success = invoke(dev,'ConnectZBUS',dev_interface);
        if ~success
            error(sprintf('Error connecting to ZBUS via %s',dev_interface));
        end
    case {'PA5'} % trying to add a pa5
        dev = actxcontrol('PA5.x',[0 0 0 0]);
        success = invoke(dev,'ConnectPA5',dev_interface,dev_number);
        if ~success
            error(sprintf('Error connecting to PA5 num %d via %s',dev_number,dev_interface));
        end
    case {'RP2' 'RX6' 'RM2' 'RA16' 'RV8'} % any RPCo.x device
        % define the activeX controller
        dev = actxcontrol('RPCo.x',[0 0 0 0]);
        % connect to the device
        if ~invoke(dev,['Connect' dev_type],dev_interface,dev_number);
            error(sprintf('Error connecting to %s num %d via %s',dev_type,dev_number,dev_interface));
        end
        % load a circuit (set the samprate if it was given as argument)
        if isempty(dev_samprate)
            success = invoke(dev,'LoadCOF',dev_circuit);
        else
            % let users enter a real sampling rate; translate to TDT lingo
            switch round(dev_samprate)
                case 6000
                    tdt_fs = 0;
                case 12000
                    tdt_fs = 1;
                case 25000
                    tdt_fs = 2;
                case 50000
                    tdt_fs = 3;
                case 100000 
                    tdt_fs = 4;
                case 200000
                    tdt_fs = 5;
                otherwise
                    error('Choose a sampling rate from 6000, 12000, 25000, 50000, 100000, or 200000 Hz');
            end
            success = invoke(dev,'LoadCOFsf',dev_circuit,tdt_fs);
        end
        if ~success
            error(sprintf('Error loading circuit %s to %s num %d',dev_circuit,dev_type,dev_number));
        end
        % start the device
        if ~invoke(dev,'Run');
            error(sprintf('Error starting %s num %d',dev_type,dev_number));
        end
        % add the samprate, circuit file, and par tag names to the object
        samprate = invoke(dev,'GetSFreq');
        numtags = invoke(dev,'GetNumOf','ParTag');
        mytags = {};
        for itag = 1:numtags
            mytags{itag} = invoke(dev,'GetNameOf','ParTag',itag);
        end

        % add device-specific info to the presenter object slots
        p.samprate.(dev_type)(dev_number) = samprate;
        p.circuit_files.(dev_type){dev_number} = dev_circuit;
        p.partags.(dev_type){dev_number} = mytags;
end

%  add the device to the presenter object
p.devices.(dev_type)(dev_number) = dev;

% keep track of the commands necessary to load this object
p.add_commands{end+1} = {dev_type dev_interface dev_circuit dev_samprate};



