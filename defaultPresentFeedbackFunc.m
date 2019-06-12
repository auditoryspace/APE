function r = defaultPresentFeedbackFunc(r,varargin)
%function r = defaultPresentFeedbackFunc(r,varargin)
%function r = defaultPresentFeedbackFunc(r,feedbackstring)
%function r = defaultPresentFeedbackFunc(r)
%
% This is the default presentFeedback function. Such functions take a responder
% object <r> as the first argument. Other arguments are optional.
% In this case, the default behavior is to echo the response, adding 
% <feedbackstring> if provided, on the command line. 
%
% Other presentFeedbackFuncs might set or read tags from a presenter object
% <p> (e.g. for RBOX) or from a gui (whose handles might be stored in
% r.params. 
%
% Any number of variables can be passed through to this function using
% varargin.
%
% invoked by r = goPresentFeedback(r,varargin)

theresp = get(r,'respdata','resp');

if nargin > 1
    feedbackstring = varargin{1};
else
    feedbackstring = '';
end

fprintf('Response %s: %s\n',theresp,feedbackstring);

