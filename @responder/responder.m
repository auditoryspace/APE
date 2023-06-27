function r = responder(varargin)
% function r = responder(varargin)
%
% Constructor for responder object. The responder object <r> handles
% communication with the subject (lighting LEDs, recording button presses,
% etc). This can involve interaction with a presenter object <p>, e.g. in the
% case of experiments that used TDT's RBOX, or it might handle drawing to
% and reading from a MATLAB GUI. Responder's relationship to <p> and to the
% central experiment control program is similar to that of the stim object.
% Both stim and responder define functions that map from experimental
% parameters (visible to the control program) to specific presenter tags.
%
% In APE, subclass functionality is implemented by replacing various
% function handles stored as object slots, typically these are: 
%   prepResponseFunc      % prepares the response (reset/redraw/etc)
%   getResponseFunc      % records and returns the response data
%   presentFeedbackFunc  % presents feedback (colors buttons, lights LEDs)
%   waitForSubjectFunc   % basic response, waiting to begin trial
%   tellDoneFunc         % communicate end of run to participant
%
% The above functions are not called directly from an experiment program,
% instead they are invoked in the form
% r = goGetResponse(r,arg1,arg2,...,argN); 
% which passes the relevant arguments (argX) to the corresponding function. 
% This way, experiments can be written abstractly, and swapping in a new
% responder (e.g. exchanging hardware button box with a GUI) is trivial. 
%
% Collections of these functions appropriate for different types of
% responder objects have already been implemented. Call this constructor
% function with argument 'type' to set up automatically, e.g.:
% r = responder('type','gui2');
%
% Available types:
%   commandLine
%   rbox          % old TDT rbox
%   ardbox        % arduino hardware USB interface to TDT rbox
%   gui           % gui buttons on a window
%   gui2          % gui buttons on a window, improved
%   touchLine     % gui window recording touches on a screen w/ graphics
%   touchPath     % gui window recording drags on a screen w/ graphics
%   knobBoxA      % old SPACElab analog knob box
%   headtrack     % old SPACElab Polhemus headtrack response
%
% (c) 2008-2023 G. Christopher Stecker for Auditory Space, LLC

switch nargin
    case 0 % create an empty responder object
        r.respData = struct;  % structure of response data
        r.params = struct; % structure of responder params 
        r.prepResponseFunc = @defaultPrepResponseFunc; % prepare to read response
        r.getResponseFunc = @defaultGetResponseFunc; % function to get a response 
        r.presentFeedbackFunc = @defaultPresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @defaultWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @defaultTellDoneFunc; % tell them we're done
        
        r = class(r,'responder');
        
    otherwise % has been called with name,value pairs. Use these to fill slots

        r = responder; % first create a blank one.

        for iArg = 1:2:nargin % fill the slots
            slotname = varargin{iArg};
            slotval = varargin{iArg+1};

            if strcmp(slotname,'type')
                r = default_type(r,slotval);
            elseif ~isfield(struct(r),slotname)
                fprintf('\n%s is not a valid stim slot name.',slotname);
            else
                eval(sprintf('r.%s = slotval;',slotname));
            end
        end
end


%%%------------------------
%%% default_type: set up function handles for one of several default
%%%     responder types
%%%------------------------

function r = default_type(r,type)

switch type
    case 'commandline'
        r.prepResponseFunc = @defaultPrepResponseFunc; % prepare to read response
        r.getResponseFunc = @defaultGetResponseFunc; % function to get a response 
        r.presentFeedbackFunc = @defaultPresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @defaultWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @defaultTellDoneFunc; % tell them we're done
    case 'rbox'
        r.prepResponseFunc = @rboxPrepResponseFunc; % prepare to read response
        r.getResponseFunc = @rboxGetResponseFunc; % function to get a response 
        r.presentFeedbackFunc = @rboxPresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @rboxWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @rboxTellDoneFunc; % tell them we're done
    case 'ardbox' % Arduino controller with attached TDT RBOX
        r.prepResponseFunc = @ardboxPrepResponseFunc; % prepare to read response
        r.getResponseFunc = @ardboxGetResponseFunc; % function to get a response 
        r.presentFeedbackFunc = @ardboxPresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @ardboxWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @ardboxTellDoneFunc; % tell them we're done
        r.params.device = ardboxInitFunc; % initialize the USB interfact and store in params
    case 'gui'
        r.prepResponseFunc = @defaultPrepResponseFunc; % prepare to read response
        r.getResponseFunc = @guiGetResponseFunc; % function to get a response 
        r.presentFeedbackFunc = @guiPresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @guiWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @guiTellDoneFunc; % tell them we're done
    case 'gui2'
        r.prepResponseFunc = @gui2PrepResponseFunc; % prepare to read response
        r.getResponseFunc = @gui2GetResponseFunc; % function to get a response 
        r.presentFeedbackFunc = @gui2PresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @guiWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @guiTellDoneFunc; % tell them we're done
    case 'touchline'
        r.prepResponseFunc = @defaultPrepResponseFunc; % prepare to read response
        r.getResponseFunc = @touchlineGetResponseFunc; % function to get a response 
        r.presentFeedbackFunc = @touchlinePresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @touchlineWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @touchlineTellDoneFunc; % tell them we're done
    case {'touchpath' 'touchPath'}
        r.prepResponseFunc = @touchpathPrepResponseFunc; % prepare to read response
        r.getResponseFunc = @touchpathGetResponseFunc; % function to get a response 
        r.presentFeedbackFunc = @touchpathPresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @touchpathWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @touchpathTellDoneFunc; % tell them we're done
    case 'knobBoxA'
        r.waitForSubjectFunc = @knobBoxAWaitForSubjectFunc;
    case {'headtrack' 'headTrack'}
        r.prepResponseFunc = @headtrackPrepResponseFunc; % prepare to read response
        r.getResponseFunc = @headtrackGetResponseFunc; % function to get a response 
 %       r.presentFeedbackFunc = @rboxPresentFeedbackFunc; % func to present feedback
        r.waitForSubjectFunc = @headtrackWaitForSubjectFunc; % wait to start
        r.tellDoneFunc = @headtrackTellDoneFunc; % tell them we're done
    case 'BussSR'
        r.prepResponseFunc = @BussSRPrepResponseFunc;
        r.getResponseFunc = @BussSRGetResponseFunc;
        r.waitForSubjectFunc = @BussSRWaitForSubjectFunc;
        r.tellDoneFunc = @BussSRTellDoneFunc; % tell them we're done

end
        

