function s = set(s,varargin)

slotname = varargin{1};
slotval = varargin{2};

switch slotname
    case 'params'
        if nargin==3
            s.params = slotval;
        else
            for iparam = 2:2:length(varargin)

                paramname = varargin{iparam};
                paramval = varargin{iparam+1};
                s.params.(paramname) = paramval;
            end
        end
    case 'tags'
        if nargin==3
            s.tags = slotval;
        else
            for itag = 2:2:length(varargin)

                tagname = varargin{itag};
                tagval = varargin{itag+1};
                s.tags.(tagname) = tagval;
            end
        end
    case 'makeStimFunc'
        s.makeStimFunc = slotval;
    case 'readyFunc'
        s.readyFunc = slotval;
    case 'presentFunc'
        s.presentFunc = slotval;

    otherwise
        error(sprintf('invalid slotname: %s',slotname));
end