function r = headtrackGetResponseFunc(r,p,varargin)
%function r = headtrackGetResponseFunc(r,p)
%function r = headtrackGetResponseFunc(r,p,'reset')
%function r = headtrackGetResponseFunc(r,p,'immediate')
%function r = headtrackGetResponseFunc(r,p,'logAH','immediate')
%
% This is a getResponse function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, <r> interacts with presenter object <p> to read from the 
% TDT HTI3. After this call, r.respdata will have the following structure:
%   button: (button pressed by subject)
%   reactiontime: (time from function call to button press, in seconds)
%
% including 'reset' as argument 3 or 4 will cause response reset before
% collection
%
% including string argument 3 or 4 beginning with 'log' will include head
% logs in r.respdata (e.g.: 'logA' logs Azim, 'logE' logs Elev',
%       'logALE' logs Azim, LeftRight, and Elev,
%       'logAH' logs Azim and Home);
%
% string argument 'immediate' will cause azim and logs to be read out
% immediately, without waiting for button press. 
%
% invoked by r = goGetResponse(r,varargin)

tic % set a timer

logAzim = 0;
logElev = 0;
logLeftRight = 0;
immediate = 0;

for i = 1:length(varargin)
    if strcmp(varargin{i},'immediate') 
        % read immediately, no wait for button [CS 11/6/09]
        immediate = 1;
    end
    if strcmp(varargin{i},'reset')
        soft_trig(p,10); % reset the button box
    end
    if strmatch('log',varargin{i})
        foo = varargin{i}(4:end);
        if strfind(foo,'A')
            logAzim = 1;
        end
        if strfind(foo,'E')
            logElev = 1;
        end
        if strfind(foo,'L')
            logLeftRight = 1;
        end
        if strfind(foo,'H')
            logHome = 1;
        end
    end
end

if immediate % no button press
    mydata.button = 0;
    mydata.reactiontime = nan;
else
    while ~get_tag_val(p,'Button_Press') % wait for a button press
    end

    rt = toc; % record reaction time
    which_but = get_tag_val(p,'Which_But'); % which button was pressed

    mydata.button = log2(which_but)+1; % assemble result
    mydata.reactiontime = rt;
end

mydata.azim = get_tag_val(p,'Azim');
mydata.elev = get_tag_val(p,'Elev');
mydata.leftRight = get_tag_val(p,'LeftRight');

if logAzim || logElev || logLeftRight
    logIndex = get_tag_val(p,'LogIndex');
    mydata.buttonLogTime = get_tag_val(p,'ButtonLogTime'); % time of button press in Log samples
    mydata.buttonLogRT = (mydata.buttonLogTime*60) ./ get(p,'samprate');
    mydata.logTimeBase = linspace(0,(logIndex*60)./get(p,'samprate'),logIndex); % 
    
    if logAzim % read the AzimLog
        mydata.azimLog = get_tag_val(p,'AzimLog','npoints',logIndex);
    end
   if logLeftRight % read the LeftRightLog
        mydata.leftRightLog = get_tag_val(p,'LeftRightLog','npoints',logIndex);
    end
   if logElev % read the ElevLog
        mydata.elevLog = get_tag_val(p,'ElevLog','npoints',logIndex);
    end
   if logHome % read the HomeLog
        mydata.homeLog = get_tag_val(p,'HomeLog','npoints',logIndex);
    end
end

r = set(r,'respData',mydata);