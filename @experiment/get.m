function val = get(ex,varargin)

slotname = varargin{1};

switch slotname

    case 'params'
        if nargin == 2
            val = ex.params;
        else
            paramname = varargin{2};
            val = ex.params.(paramname);
        end
    case 'status'
        if nargin == 2
            val = ex.status;
        else
            paramname = varargin{2};
            val = ex.status.(paramname);
        end
    case 'stimparams'
        if nargin == 2
            val = ex.stimparams;
        else
            paramname = varargin{2};
            val = ex.stimparams.(paramname);
        end
    case 'presenter'
        if nargin == 2
        val = ex.presenter;
        else
            pNumber = varargin{2};
            val = ex.presenter(pNumber);
        end
    case 'responder'
        val = ex.responder;
    case 'tracker'
        if nargin == 2
            val = ex.tracker;
        else
            trackNumber = varargin{2};
            val = ex.tracker(trackNumber);
        end
    case 'stim_templates'
        if nargin == 2 % all stim are returned
            val = ex.stim_templates;
        elseif isstruct(ex.stim_templates) % a named stim is requested ('A')
            templateName = varargin{2};
            val = ex.stim_templates.(templateName);
        elseif length(ex.stim_templates)>1 % an indexed stim is requested (1) 
            templateNumber = varargin{2}; 
            if isstr(templateNumber) % fix problem if string comes in rather than index
                foo = str2num(templateNumber); 
                if isempty(foo) % called with 'A' 'B' not '1' '2'
                    foo = double(templateNumber)-64; % this will give 1:4 for A:D etc
                    if foo>length(ex.stim_templates)
                        foo = foo-31; % this gives 1:4 for a:d etc
                    end
                end
                templateNumber = foo; % if it's not straightened out by now, give an error
            end
            val = ex.stim_templates(templateNumber);
        else % there is only one stim_template. return it
            val = ex.stim_templates;
        end
    case 'trial_stim'
        if nargin == 2
            val = ex.trial_stim;
        else
            intervalNumber = varargin{2};
            val = ex.trial_stim(intervalNumber);
        end
        
    case 'trialdata'
        switch nargin
            case 2
                val = ex.trialdata;

            case 3
                paramname = varargin{2};
                if isnumeric(paramname)
                    trialnum = paramname;
                    val = ex.trialdata(trialnum); % asking for a particular trial
                else
                    val = cat(1,ex.trialdata.(paramname)); % asking for a field
                end

            case 4
                trialnum = varargin{2};
                paramname = varargin{3};
                val = ex.trialdata(trialnum).(paramname);
        end
    case 'currentTrial'
        val = ex.status.currentTrial;
    case 'paused'
        val = ex.status.paused;

    case 'initFunc'
        val = ex.initFunc;
    case 'prepTrialFunc'
        val = ex.prepTrialFunc;
    case 'presentTrialFunc'
        val = ex.presentTrialFunc;
    case 'reportTrialFunc'
        val = ex.reportTrialFunc;
    case 'pauseFunc'
        val = ex.pauseFunc;
    case 'resumeFunc'
        val = ex.resumeFunc;
    case 'saveDataFunc'
        val = ex.saveDataFunc;
    case 'wrapupFunc'
        val = ex.wrapupFunc;

    otherwise
        error(sprintf('invalid slotname: %s',slotname));
end