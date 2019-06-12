function val = get(r,varargin)

slotname = varargin{1};

switch slotname
    case 'params'
        if nargin == 2
            val = r.params;
        else
            paramname = varargin{2};
            val = r.params.(paramname);
        end
    case 'paramnames'
        val = fieldnames(r.params);

    case 'respData'
        if nargin == 2
            val = r.respData;
        else
            dataname = varargin{2};
            val = r.respData.(dataname);
        end
    case 'getResponseFunc'
        val = r.getResponseFunc;
    case 'presentFeedbackFunc'
        val = r.presentFeedbackFunc;
        
    otherwise
        error(sprintf('invalid slotname: %s',slotname));
end