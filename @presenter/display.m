function display(p)
% display function for presenter objects. This governs how they appear
% in the matlab console

fprintf('\n%s = \n\nPresenter object [%d x %d]\n\n',inputname(1),size(p,1),size(p,2));

if size(p) == 1
    dev_types = fieldnames(p.devices);
    
    for i = 1:length(dev_types)
        dev_type = dev_types{i};
        num_devs = length(getfield(p.devices,dev_type));
        for dev_number = 1:num_devs
            
            % for devices with circuites (not PA5), print more info
            if isfield(p.circuit_files,dev_type)
                
                % diplay circuit file and samprate info for each device
                fprintf('\t%s(%d) %s (%.2f Hz)\n',dev_type,dev_number,p.circuit_files.(dev_type){dev_number},p.samprate.(dev_type)(dev_number));
                % format the parameter tags for simple display
                fprintf('\t  Parameter tags:\n');
                partags = p.partags.(dev_type){dev_number};
                tagstring = '';
                while ~isempty(partags)
                    tagstring = [tagstring ' ' partags{1}];
                    if length(tagstring) >= 40
                        fprintf('\t\t%s\n',tagstring);
                        tagstring = '';
                    end
                    partags = partags(2:end);
                end
                if ~isempty(tagstring), fprintf('\t\t%s\n',tagstring); end
            elseif strcmp(dev_type,'PA5');
                % for a PA5, display the atten value
                fprintf('\t%s(%d): %.2f dB\n',dev_type,dev_number,invoke(p.devices.(dev_type)(dev_number),'GetAtten'));
            else
                % otherwise, do the default
                fprintf('\t%s(%d)\n',dev_type,dev_number);
            end
        end
    end
end
disp(' ');
