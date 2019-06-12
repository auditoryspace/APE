function p = set_tag_val(p,partag,parval,varargin)
% function p = set_tag_val(p,partag,parval)
% function p = set_tag_val(p,partag,parval,'dev_type',dev_type,'dev_number',dev_number)
% function p = set_tag_val(p,partag,parval,'offset',offset)
%
% Set a parameter tag running on an RP2, etc.
%
% p: the presenter object
% partag: the name of the tag to set (defined in RPVDS)
% parval: the value to set the tag to
%
% additional arguments can be specified as <keyword,value> pairs:
%
% 'dev_type' 'dev_number': used to specify device type (e.g. 'RP2') and
%   number. By default, set_tag_val will search for and use the first
%   matching parameter tag across devices (this works great for presenters
%   with only one RP device, or where the RP devices run different circuits
%   with distinct tags. You must specify BOTH of these together.
% 'offset': for parvals longer than one element, specifies ofset for
%   writing into buffer with "writeTagV." The default offset is 0.
%
% Examples:
%   p = set_tag_val(p,'ToneFreq',500);
%   p = set_tag_val(p,'ToneAmp',2,'dev_type','RP2','dev_number',2); % set on the second RP2
%   = = set_tag_val(p,'Sig_L',mysig,'offset',500) % 500-sample offset

dev_type = [];
dev_number = [];
offset = 0;

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
                    error(['Parameter tag ' '' partag '' ' not found.']);
                end
                dev_number = 1;
            end
        end
    end
end

% now dev_type and dev_number specify the device implementing this tag
dev = p.devices.(dev_type)(dev_number);

switch dev_type
    case {'local_audio'}
        % for local audio, presenter object contains the tag data directly in
        % its userdata
        %     dev.userdata.(partag) = parval;
        ud = get(dev,'UserData');
        ud.(partag) = parval;
        set(dev,'UserData',ud);
        
        %p.devices.(dev_type)(dev_number).userdata.(partag) = parval;
    case {'Dante' 'PsychPortAudio'}
        % handle to Dante / PsychPortAudio is stored in the UIcontrol's
        % UserData
        ud = get(dev,'UserData');
        ph = ud.PsychPortAudioDevice;
        
        switch partag
            case 'PBSig'
                % parval should be a multichannel signal (eg, Nx64)
                % but we could be selecting output channels, i.e. to play
                % 2-channel audio to chans [57 9] not [1 2]
                %
                
                % create the full signal for all channels:
                fullsig = zeros(ud.NumTotalChans,size(parval,2));
                % put the data into the requested channels (PBchans)
                fullsig(ud.PBChans,:) = parval;
                
                % CALIBRATE loudspeaker gains and delays
                if strmatch('delays',get(p,'partags'))
                    delays = get_tag_val(p,'delays');
                    if length(delays) ~= ud.NumTotalChans
                        error('Size mismatch between delays vector and audio device');
                    else
                        fullsig = compensate_RIR_delay(fullsig,delays);
                    end
                end
                    
                if strmatch('gains',get(p,'partags'))
                    gains = get_tag_val(p,'gains');
                    if length(gains) ~= ud.NumTotalChans
                        error('Size mismatch between gains vector and audio device');
                    else
                        fullsig = compensate_RIR_gain(fullsig,gains);
                    end
                end

                
                % then upload to ph
                PsychPortAudio('FillBuffer',ph,fullsig);
                
                ud.PBSamps = size(fullsig,2);  % store the number of samples. 
                
                
                % case 'RecSig'
                % writing into the record buffer? I think you're confused.
                % no it's cool. handle this in the 'otherwise' case
            otherwise
                ud.(partag) = parval;
        end
        set(dev,'UserData',ud);
        
        %p.devices.(dev_type)(dev_number).userdata.(partag) = parval;
        
        
    otherwise
        if length(parval)==1
            invoke(dev,'SetTagVal',partag,parval);
        else
            if size(parval,2) == 1
                parval = parval'; % force to row vector
            end
            invoke(dev,'WriteTagV',partag,offset,parval);
        end
end

