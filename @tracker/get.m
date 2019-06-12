function val = get(t,varargin)

slotname = varargin{1};

switch slotname
    case 'type'
        val = t.type;
    case 'params'
        if nargin == 2
            val = t.params;
        else
            paramname = varargin{2};
            val = t.params.(paramname);
        end
    case 'status'
        if nargin == 2
            val = t.status;
        else
            paramname = varargin{2};
            val = t.status.(paramname);
        end
    case 'trialdata'
        switch nargin
            case 2
                val = t.trialdata;

            case 3
                paramname = varargin{2};
                if isnumeric(paramname)
                    trialnum = paramname;
                    val = t.trialdata(trialnum); % asking for a particular trial
                else
                    val = cat(1,t.trialdata.(paramname)); % asking for a field
                end
                
            case 4
                trialnum = varargin{2};
                paramname = varargin{3};
                val = t.trialdata(trialnum).(paramname);
        end
    case 'updateFunc'
        val = t.updateFunc;
    case 'nextValueFunc'
        val = t.nextValueFunc;

    otherwise
        error(sprintf('invalid slotname: %s',slotname));
end