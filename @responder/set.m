function r = set(r,varargin)

slotname = varargin{1};
slotval = varargin{2};

switch slotname
    case 'respData'
        if nargin==3 % three input args: r, 'respdata', newrespdata
            r.respData = slotval;
        else % four input args? r, 'respdata', dataslot, dataval
            for iparam = 2:2:length(varargin)
                paramname = varargin{iparam};
                paramval = varargin{iparam+1};
                r.respData.(paramname) = paramval;
            end
        end
    case 'params'
        if nargin==3 % three input args: r, 'params', newparams
            r.params = slotval;
        else % four input args? r, 'params', paramslot, paramval
            for iparam = 2:2:length(varargin)
                paramname = varargin{iparam};
                paramval = varargin{iparam+1};
                r.params.(paramname) = paramval;
            end
        end
    case 'prepResponseFunc'
        r.prepResponseFunc = slotval;
    case 'getResponseFunc'
        r.getResponseFunc = slotval;
    case 'waitForSubjectFunc'
        r.waitForSubjectFunc = slotval;
    case 'tellDoneFunc'
        r.tellDoneFunc = slotval;
    case 'presentFeedbackFunc'
        s.presentFeedbackFunc = slotval;
    otherwise
        error(sprintf('invalid slotname: %s',slotname));
end