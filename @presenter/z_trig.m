function p = z_trig(p,AB,racks,type,delay)
% function p =z_trig(p,AB,racks,type,delay)
%
% Send zBUS trigger to start multiple RP devices simultaneously.
%
% p: presenter object
% ab: literally 'A' (default) or 'B' to specify one of two named zTrigs
% racks: which TDT caddie to trigger. 0 (default) specifies all racks
% type: 0 = single pulse (default), 1 = high, 2 = low
% delay: trigger after <delay> ms. Min of 2 ms per rack. Default 8 ms.

% set defaults
if nargin<5
    delay = 8;
    if nargin<4
        type = 0;
        if nargin<3
            racks = 0;
            if nargin<2
                AB = 'A';
            end
        end
    end
end

% if user didn't add the ZBUS device, do it now.
if ~isfield(p.devices,'ZBUS') | isempty(p.devices.ZBUS)
    error('Must add ZBUS device to use z_trig.');
end

dev = p.devices.ZBUS(1);
invoke(dev,['zBusTrig' AB],racks,type,delay);
