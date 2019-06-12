function r = defaultGetResponseFunc(r,myprompt)
%function r = defaultGetResponseFunc(r,myprompt)
%
% This is the default getResponse function. Such functions take a responder
% object <r>. Other arguments are optional. In this case,
% getResponse will simply prompt for user input with input(), store the
% resulting string in r.respdata.resp and reaction time in
% r.respdata.reactiontime
%
% Other getResponseFuncs might set and read tags from <p> (e.g. for RBOX).
% Any number of variables can be passed through to this function using
% varargin.
%
% invoked by r = goGetResponse(r,varargin)

if nargin > 1
    r = set(r,'params','prompt',myprompt);
end

if isfield(get(r,'params'),'prompt')
    prompt = get(r,'params','prompt');
else
    prompt = '>';
end

tic
mydata.resp = input(prompt,'s'); % unevaluated string
mydata.reactiontime = toc; % reaction time in seconds 

r = set(r,'respData',mydata);