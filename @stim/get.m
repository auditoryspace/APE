function val = get(s,varargin)

slotname = varargin{1};

switch slotname
    case 'tags'
        if nargin == 2
            val = s.tags;
        else
            tagname = varargin{2};
            val = s.tags.(tagname);
        end
    case 'tagnames'
        val = fieldnames(s.tags);

    case 'params'
        if nargin == 2
            val = s.params;
        else
            paramname = varargin{2};
            val = s.params.(paramname);
        end
    case 'makeStimFunc'
        val = s.makeStimFunc;
    case 'readyFunc'
        val = s.readyFunc;
    case 'presentFunc'
        val = s.readyFunc;
        
    otherwise
        error(sprintf('invalid slotname: %s',slotname));
end