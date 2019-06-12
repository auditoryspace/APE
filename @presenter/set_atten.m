function p = set_atten(p,atten_num,atten_val,varargin)
% function p = set_atten(p,atten_num,atten_val)
%
% Set an attenuator value
%
% p: the presenter object
% atten_num: which attenuator to set
% atten_val: attenuation value
%
% By default, this function will set the attenuation values on PA5 devices.
% In that case, <atten_num> refers to the order of devices added to the
% presenter object (typically, PA5#1 is added first, etc.). 
%
% If <p> does not contain PA5 devices (for example, when running an RM2), 
% then set_atten calls set_tag_val, using the tag name "atten_X" where X 
% stands for <atten_num>. Designing RPVDS circuits to define such tags can
% allow transparent movement of code from RP2/PA5 systems to RM2 systems.
%
%
% Examples:
%   p = set_atten(p,1,24); % set atten 1 to 24 dB

if ~isfield(p.devices,'PA5') | isempty(p.devices.PA5)
    p = set_tag_val(p,['atten_' num2str(atten_num)],atten_val);
    return;
end

if length(p.devices.PA5) < atten_num
    error('Requested attenuator number exceeds number of defined PA5 devices');
end

dev = p.devices.PA5(atten_num);;
invoke(dev,'SetAtten',atten_val);
