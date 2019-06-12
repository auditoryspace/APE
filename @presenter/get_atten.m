function val = get_atten(p,atten_num)
% function val = get_atten(p,atten_num)
%
% Read an attenuator value
%
% p: the presenter object
% atten_num: which attenuator to read
%
% By default, this function will read attenuation values from PA5 devices.
% In that case, <atten_num> refers to the order of devices added to the
% presenter object (typically, PA5#1 is added first, etc.). 
%
% If <p> does not contain PA5 devices (for example, when running an RM2), 
% then get_atten calls get_tag_val, using the tag name "atten_X" where X 
% stands for <atten_num>. Designing RPVDS circuits to define such tags can
% allow transparent movement of code from RP2/PA5 systems to RM2 systems.
%
%
% Examples:
%   my_atten = get_atten(p,1); % read atten value on first PA5

if ~isfield(p.devices,'PA5') | isempty(p.devices.PA5)
    val = get_tag_val(p,['atten_' num2str(atten_num)]);
    return;
end

if length(p.devices.PA5) < atten_num
    error('Requested attenuator number exceeds number of defined PA5 devices');
end

dev = p.devices.PA5(atten_num);
val = invoke(dev,'GetAtten');
