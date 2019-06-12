function val = get_tag_val(p,partag,varargin)
% function val = get_tag_val(p,partag)
% function val = get_tag_val(p,partag,'dev_type',dev_type,'dev_number',dev_number)
% function val = get_tav_val(p,partag,'offset',offset,'npoints',npoints)
%
% Read data from a parameter tag running on an RP2, etc. Calling without dev_type and
% dev_number will search for and use the first matching parameter tag
% across devices (this works great for presenters with only one RP device,
% or where the RP devices run different circuits with distinct tags. Call
% with dev_type and dev_number to specify.
%
% p: the presenter object
% partag: the name of the tag to set (defined in RPVDS)
% parval: the value to set the tag to
%
% additional arguments can be specified as <keyword,value> pairs:
%
% 'dev_type' 'dev_number': used to specify device type (e.g. 'RP2') and
%   number. By default, get_tag_val will search for and use the first
%   matching parameter tag across devices (this works great for presenters
%   with only one RP device, or where the RP devices run different circuits
%   with distinct tags. You must specify BOTH of these together.
% 'npoints': when given, instructs get_tag_val to invoke the activeX call
%   'readTagV' (rather than 'getTagVal') and read this many points from
%   that tag (which should point to a buffer or similar)
% 'offset': along with 'npoints,' specifies the offset into a buffer to
%   begin reading. The default offset is 0.
%

% Examples:
%   val = get_tag_val(p,'ToneFreq');
%   val = get_tag_val(p,'ToneAmp','dev_type','RP2','dev_number',2); % get ToneAmp from second RP2
%   val = get_tag_val(p,'RecordBuffer','offset',0,'npoints',1000); % read
%       first 1000 points in RecordBuffer


dev_type = [];
dev_number = [];
offset = 0;
npoints = 1;

for iarg = 1:2:length(varargin)
    keyword = varargin{iarg};
    eval([keyword ' = varargin{iarg+1};']);
end

if isempty(dev_type)
    % first find the device that defines this tag
    foundit = 0;
    dev_types = fieldnames(p.partags);
    i_dev = 1;
    dev_number = 1;
    
    % start looking in the tags of the first device with tags. progress from
    % there
    while ~foundit
        dev_type = dev_types{i_dev};  % RP2, RM2, etc.
        if ismember(partag,p.partags.(dev_type){dev_number})
            foundit = 1;
        else
            dev_number = dev_number+1;
            if dev_number > length(p.partags.(dev_type))
                i_dev = i_dev + 1;
                if i_dev > length(dev_types)
                    error(sprintf('Parameter tag %s not found.',partag));
                end
                dev_number = 1;
            end
        end
    end
end

% now dev_type and dev_number specify the device implementing this tag
dev = p.devices.(dev_type)(dev_number);

switch dev_type
    case {'local_audio' }
        % for local audio presenter object contains the tag data directly in
        % its userdata
        ud = get(dev,'UserData');
        val = ud.(partag);
    case {'Dante' 'PsychPortAudio'}
        % for  Dante, presenter object contains most tag data directly in
        % its userdata
        ud = get(dev,'UserData');
        switch partag
            case 'RecSig'
                if ~ud.Blocking
                    % in blocking playback, the RecSig tag will not be
                    % filled automatically. Need to get the rec data
                    % directly from the PsychPortAudio device
                    ph = ud.PsychPortAudioDevice;
                    audiodata = PsychPortAudio('GetAudioData', ph);
                    
                    recchan = ud.RecChans; % which channels to record
                    if ~isempty(recchan)
                        audiodata = audiodata(recchan,:); % return only the requested channels
                    end
                    
                    val = audiodata; % note that if RecChans is empty, then return ALL channels (seems odd not to specify though).
                else
                    val = ud.RecSig;
                end
            otherwise
                val = ud.(partag);
        end
        
    otherwise
        if npoints == 1
            val = invoke(dev,'GetTagVal',partag);
        else
            val = invoke(dev,'ReadTagV',partag,offset,npoints);
        end
end
