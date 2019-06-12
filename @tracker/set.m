function t = set(t,varargin)


slotname = varargin{1};
slotval = varargin{2};

switch slotname
    case 'type'
        t.type = slotval;
    case 'params'
        if nargin==3
            t.params = slotval;
        else
            for iparam = 2:2:length(varargin)

                paramname = varargin{iparam};
                paramval = varargin{iparam+1};
                t.params.(paramname) = paramval;
            end
        end
    case 'status'
        if nargin==3
            t.status = slotval;
        else
            for iparam = 2:2:length(varargin)

                paramname = varargin{iparam};
                paramval = varargin{iparam+1};
                t.status.(paramname) = paramval;
            end
        end
    case 'trialdata'
        switch nargin
            case 3
                % setting trialdata field directly & in full
                t.trialdata = slotval;
            case 5
                % setting one field of one trial
                trialnum = varargin{2};
                paramname = varargin{3};
                paramval = varargin{4};
                t.trialdata(trialnum).(paramname) = paramval;
            case 4
                for iparam = 2:2:length(varargin)
                    paramname = varargin{iparam};
                    paramval = varargin{iparam+1};
                    if isnumeric(paramname)
                        trialnum = paramname;
                        % setting one trial of trialdata..paramval is a
                        % trialdata structure
                        t.trialdata(trialnum) = paramval;
            
                    else
                        % setting one of the trialdata fields
                        
                        % If sent a 1-by-ntrials (cell or other) array, then assign each
                        % element to one of the trials. If sent a single
                        % value, then assign it to every trial. If sent
                        % something else, an error will likely occur
                        if iscell(paramval)
                            [t.trialdata.(paramname)] = deal(paramval{:});
                        else
                            % need to use cell arrays for deal, so
                            % convert first
                            cellval = num2cell(paramval);
                            [t.trialdata.(paramname)] = deal(cellval{:});
                        end
                    end
                end

        end
                
    case 'initFunc'
        t.initFunc = slotval;
    case 'updateFunc'
        t.updateFunc = slotval;
    case 'nextValueFunc'
        t.nextValueFunc = slotval;
    case 'plotFunc'
        t.plotFunc = slotval;
    case 'reportFunc'
        t.reportFunc = slotval;
        

    otherwise
        error(sprintf('invalid slotname: %s',slotname));
end