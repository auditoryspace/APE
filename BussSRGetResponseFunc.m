function r = BussSRGetResponseFunc(r)
%function r = BussSRGetResponseFunc(r)
%
% BussSR is an APE module implementing Emily Buss' Sentence Response
% interface for sentences with keywords. As part of APE, this code is (c)
% 2023, Auditory Space, LLC but includes code from Emily Buss and should be
% credited thusly. Please inquire regarding how to properly cite this work.
%
% The APE responder class provides an abstract definition of particpant
% response interface, consisting primarily of the following function
% handles: 
%
%   prepResponseFunc      % prepares the response (reset/redraw/etc)
%   getResponseFunc      % records and returns the response data
%   presentFeedbackFunc  % presents feedback (colors buttons, lights LEDs)
%   waitForSubjectFunc   % basic response, waiting to begin trial
%   tellDoneFunc         % communicate end of run to participant
%
% This function, BussSRGetResponseFunction, reads in the response data 
% from the GUI, which must be set up using BussSRPrepResponseFunction
%
% After this call, r.respdata will have the following structure:
%   reactiontime:  3.4787 (time from function call to button press, in seconds)
%          tagStr: '3,5,DONE' (intermediate data structure, not used)
%          missed: [3 5]        (index to keywords missed)
%       numMissed: 2            (number of keywords missed)
%       resultStr: 'seed into'  (key words missed)
%        numRight: 6            (number of keywords correct)
%        numWrong: 2            (number of keywords wrong)
%
% invoked by r = goGetResponse(r,varargin)
%
%
% (c) 2023 Auditory Space, LLC


respParams = get(r,'params');


tic % set a timer

f = respParams.guifig;

% loop to wait for subject response
mydata = [];
while isempty(mydata)
    drawnow;
    mydata = get(f,'UserData'); % clickme will fill f's UserData
end

mydata = struct('reactiontime',toc,'tagStr',mydata);

mydata.missed = ParseTag(mydata.tagStr);

if isempty(mydata.missed)
    mydata.resultStr = 'NONE';
    mydata.numMissed = 0;								% none missed
else
    mydata.numMissed = length(mydata.missed);
    mydata.resultStr = [];
    for i = 1:mydata.numMissed
        if i == 1
%             mydata.resultStr = respParams.tokenInfo.(sprintf('w%d',mydata.missed(i)));
            mydata.resultStr = respParams.tokenInfo.Words{mydata.missed(i)};
        else
            mydata.resultStr = sprintf('%s %s', ...
                mydata.resultStr, respParams.tokenInfo.Words{mydata.missed(i)}); 
        end
    end
end

mydata.numRight = sum(respParams.tokenInfo.KeyWords)-mydata.numMissed;
mydata.numWrong = mydata.numMissed;

set(f,'UserData',[]);

figure(f);

r = set(r,'respData',mydata);  % set the data and return


end






%%------------------------------------------------------------------%
function WFlagged = ParseTag(tagStr)


if strcmp(tagStr,'DONE'),                  % if just "done"
    WFlagged = [];                          % no words missed
elseif length(tagStr) > 5,
    pt = strfind(tagStr,',DONE');          % omit word "done"
    WFlagged = sort(str2num(tagStr(1:pt-1)));    % get word #
else
    error('unknown value for Tag');
end

end

