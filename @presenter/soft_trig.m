function p = soft_trig(p,trig_num,varargin)
% function p = soft_trig(p,trig_num)
% function p = soft_trig(p,trig_num,'dev_type',dev_type,'dev_number',dev_number)
%
% Send a trigger to device
%
% p: presenter object
% trig_num: number of softtrig to issue
%
% enter the following as <keyword,value> pairs
% dev_type and dev_num: specify device type and number to trigger. Leave
%   off for default behavior: trigger first device capable of receiving
%   software triggers (i.e. RP2 not PA5)
%
% Examples:
% soft_trig(p,10); % send soft trigger 10 to first RP device
% soft_trig(p,1,'dev_type','RX6','dev_number',2); % send to 2nd RX6

dev_type = [];
dev_number = [];

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

switch dev_type
    case {'local_audio'}
        % send the trigger to local audio? what would this mean?
        % play a sound on trigger 1
        switch trig_num
            case 1 % play a sound
                mysig = [get_tag_val(p,'SigL'); get_tag_val(p,'SigR')];
%                         c = clock; fprintf('%02d:%.05g\n',c(5),c(6));

                sound(mysig',p.samprate.(dev_type)(dev_number));
                
            otherwise % just ignore it.
                
                %             error(sprintf('%d is an invalid trigger number for local audio device',trig_num));
        end

    case {'local_audio2024'}
        % send the trigger to local audio? what would this mean?
        % play a sound on trigger 1
        switch trig_num
            case 1 % play a sound
                mysig = get_tag_val(p,'PBSig'); 
                sound(mysig',p.samprate.(dev_type)(dev_number));

            otherwise % just ignore it.

                %             error(sprintf('%d is an invalid trigger number for local audio device',trig_num));
        end

    case {'Dante' 'PsychPortAudio'}
        % send the trigger to local audio? what would this mean?
        
        
        
        % play a sound on trigger 1
        switch trig_num
            case 1 % play a sound
                ud  = get(dev,'UserData');
                ph = ud.PsychPortAudioDevice;
                % this assumes that the PPA buffer has been filled by
                % set_tag_val...
                lastSample = 0; lastTime = 0;
                
                nrep = 1;
                t0 = GetSecs;
                starttime = t0+.2; % wait 200 ms[?] then play it.
                
                % hit it:
                t1 = PsychPortAudio('Start',ph,nrep,starttime,1);
                
                blocking = ud.Blocking;
                
                if blocking
                    % this bit blocks until playback complete. BUT we don't
                    % have to do this, necessarily. Could modify later to
                    % return once playback starts.
                    while lastSample < ud.PBSamps*nrep
                        %     while s.ElapsedOutSamples < length(sig)
                        % Query current playback status and print it to the Matlab window:
                        %     fprintf('%.4f\n',GetSecs-t0); pause(0.1);
                        s = PsychPortAudio('GetStatus', ph);
                        realSampleRate = (s.ElapsedOutSamples - lastSample) / (s.CurrentStreamTime-t0 - lastTime);
                        lastSample = s.ElapsedOutSamples; lastTime = s.CurrentStreamTime-t0;
                        %     fprintf('Samples %d Time %.4f Measured average samplerate Hz: %f\n', lastSample,lastTime,realSampleRate);
                        % pause(0.2); % necessary? % commented out by CS, 2/2/2018
                        %
                    end
                    
                    % read the audio data we recorded
                    % [NOTE THAT CAN'T DO THIS PROPERLY UNLESS BLOCKING]
                    %   so for non-blocking, would have to time this outside...
                    recchan = get_tag_val(p,'RecChans'); % which channels to record
                    if ~isempty(recchan)
                        %[audiodata absrecposition overflow cstarttime] = PsychPortAudio('GetAudioData', pahandle [, amountToAllocateSecs][, minimumAmountToReturnSecs][, maximumAmountToReturnSecs][, singleType=0]);
                        audiodata = PsychPortAudio('GetAudioData', ph);
                        
                        audiodata = audiodata(recchan,:); % return only the requested channels
                        
                        p = set_tag_val(p,'RecSig',audiodata); % and store it in a tag to read back later
                    end
                end
                
            otherwise % just ignore it.
                
                %             error(sprintf('%d is an invalid trigger number for local audio device',trig_num));
        end
    otherwise
        invoke(dev,'SoftTrg',trig_num);
end