function s = ardboxInitFunc
% function ardboxInitFunc
%
% set up a serial device at /dev/cu.usbmodem* for talking to an arduino
% 

d = dir('/dev/cu.usbmodem*'); % look for potential device ports
fname = ['/dev/' d(1).name]; % use the first one
delete(instrfind('Port',fname)); % delete any previous object connected to this port
        
% then, init the serial port and open a stream to read/write:
        
s = serial(fname,'BaudRate',115200,'Timeout',300); % really opening cu.usbmodem1411
fopen(s);
        
% send some commands?
%   RB read the button data
%   SL set an led
%   SA set all 4 leds to pattern
%   LM latch mode 
%   LR latch reset

%fprintf(s,'RB\n');
%fprintf('Initializing ardbox at %s. Button data: %s\n',fname,fgetl(s)); % print the result
        