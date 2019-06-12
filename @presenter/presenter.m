function p = presenter(varargin)
%
% constructor object for presenter
%
% A presenter object is a "wrapper" for your stimulus delivery (and
% possibly user response) hardware, which could be a TDT System 3 or simply
% local audio (soundcard).

switch nargin
    case 0 % create an empty presenter object
        p.devices = struct;
        p.circuit_files = struct;
        p.samprate = struct;
        p.partags = struct;
        p.status = struct;
        p.add_commands = {};

        p = class(p,'presenter');
    otherwise % has been called with name,value pairs. Use these to fill slots

        p = presenter; % first create a blank one.

        for iArg = 1:2:nargin % fill the slots
            slotname = varargin{iArg};
            slotval = varargin{iArg+1};

            if strcmp(slotname,'type')
                p = default_type(p,slotval);
            elseif ~isfield(struct(p),slotname)
                fprintf('\n%s is not a valid presenter slot name.',slotname);
            else
                eval(sprintf('p.%s = slotval;',slotname));
            end
        end
end

function p = default_type(p,type)

switch type
    case 'localaudio'
        % I don't know what to do here yet.
end
