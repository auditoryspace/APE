function r = ardboxCloseFunc(r)
% function r = ardboxCloseFunc(r)
%
% close the serial device in r.params.s
%       at /dev/cu.usbmodem* for talking to an arduino
% 

% get the device
s = get(r,'params','device');

fclose(s); 
delete(s); % delete any previous object connected to this port
        
        