function p = reload_circuit(p,circuit_name,varargin)
% function p = reload_circuit(p,circuit_name)
% function p = reload_circuit(p,circuit_name,'samprate',samrate)
% function p = reload_circuit(p,circuit_name,'dev_type',dev_type,'dev_number',dev_number)
%
% Change or reload the circuit running on a device
%
% p: presenter object
% circuit_name: file name of circuit leave off or empty to reload current
%
% enter the following as <keyword,value> pairs
% samprate: specify sampling rate
% dev_type and dev_num: specify device type and number to trigger. Leave
%   off for default behavior: reload first device capable of running circuits
%
% Examples:
% p = reload_circuit(p,'simple_tone.rcx'); % load circuit on first RP device
% p = reload_circuit(p,[],'samprate',25000); % change samprate on current circuit
% p = reload_circuit(p,'simple_tone.rcx','dev_type','RX6','dev_number',2); % load on 2nd RX6

if nargin <2
    circuit_name = [];
end

dev_type = [];
dev_number = [];
samprate = [];

for iarg = 1:2:length(varargin)
    keyword = varargin{iarg};
    eval([keyword ' = varargin{iarg+1};']);
end

if isempty(dev_type)
    % first find the device that runs circuits
    dev_types = fieldnames(p.circuit_files);
    dev_type = dev_types{1};
    dev_number = 1;
end

dev = p.devices.(dev_type)(dev_number);
if isempty(circuit_name)
    circuit_name = p.circuit_files.(dev_type){dev_number};
end

invoke(dev,'Halt');

% load a circuit (set the samprate if it was given as argument)
if isempty(samprate)
    success = invoke(dev,'LoadCOF',circuit_name);
else
    % let users enter a real sampling rate; translate to TDT lingo
    switch round(samprate)
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
    success = invoke(dev,'LoadCOFsf',circuit_name,tdt_fs);
end
if ~success
    error(sprintf('Error loading circuit %s to %s num %d',circuit_name,dev_type,dev_number));
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
p.circuit_files.(dev_type){dev_number} = circuit_name;
p.partags.(dev_type){dev_number} = mytags;
