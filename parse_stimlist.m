function [stimParams headParams] = parse_stimlist(fname,evalFlag)
%function [stimParams headParams] = parse_stimlist(fname,evalFlag)
%
% read an APE 'stimlist' file. Such files are tab-delimited text with 
% the following structure:
%
% <head> 
% HParam1\tHParam1 Value   (field, value pair for first shared field)
% HParam2\tHParam2 Value   (field, value pair for second shared field)
% ...
% HParamX\tHParamX Value   (etc)
% <body>
% Fiel1Name\tField2Name\t...FieldNName    % 'header row with column names
% Stim1Field1\tStim1Field2...Stim1FieldN  % values for each field (stim1)
% Stim2Field1\tStim2Field2...Stim2FieldN  % values for each field (stim2)
% ...
% StimM<Field1\tStimMField2...StimMFieldN  % values for each field (etc)
%
% You can use a spreadsheet app to create and edit stimlist files.
% 
%
% Return variables are
% stimParams: struct array (1 per stim) with fields and values as defined
%   in body section of stimlist file
% headParams: struct with fields and values as defined in head section of
%   stimlist file. Optional but useful for comments, condition labels, etc. 
%
% Note that the format is completely abstract in terms of the contents
% (field names and values) and is appropriate for any type of stimulus
% configuration file. Configured correctly, <stimParams> entries should be
% suitable to pass directly to a stim object's makeStimFunc.  
%
% Stimlist was originally implemented to handle word and sentence lists,
% where each line defines a sentence, and fields include audio file name,
% sentence words, etc. 
%
% By default, parse_stimlist attempts to convert strings to numeric values. 
% Set evalFlag to 0 to prevent numeric conversion of strings in your file.  
% 
% Author: Chris Stecker (c) 2023-2024 Auditory Space, LLC. 
% 

% % convert . and .. to absolute paths
% if fname(1) == '.'
%     if fname(2) == '.'
%         cwd = pwd;
%         cd ..;
%              fname = [pwd fname(3:end)];
%         cd(cwd);
%     else
%              fname = [pwd fname(3:end)];
%     end
% end

if ~exist(fname)
    error(sprintf('File not found on path: %s',fname));
end


if nargin < 2 || isempty(evalFlag)
    evalFlag = 1;
end

noEval = {'Label' 'Path' 'File' 'Sentence'}; % in no case try to parse these as numbers


fid = fopen(fname,'r');
inHead = 1;
inBody = 0;
headParams = struct;
stimParams = struct;


while ~inBody
    theLine = fgetl(fid);
    switch(sscanf(theLine,'%s'))
        case '<head>'
            inHead = 1;
        case {'</head>' '<body>'}
            inHead = 0;
            inBody = 1;
        otherwise
            if inHead
                foo = textscan(theLine,'%s','delimiter','\t');
                if evalFlag
                    [val, ok] = str2num(foo{1}{2});
                    if ~ok
                        val = foo{1}{2};
                    end
                else
                    val = foo{1}{2};
                end
                headParams.(foo{1}{1}) = val;
            end
    end
end

% read the header line for field names
headerDone = 0;

while ~headerDone
    theLine = fgetl(fid);
    switch sscanf(theLine,'%s')
        case {'</head>' '<body>'}
            % ignore
        otherwise
            foo = textscan(theLine,'%s','delimiter','\t');
            paramFields = foo{1}; % field names
            for i = 1:length(paramFields)
                stimParams.(paramFields{i}) = [];
            end
            stimParams = stimParams(1:0);
            headerDone = 1;
            
    end
end

% now read the lines for each stim entry
iStim = 0;

while inBody
    theLine = fgetl(fid);
    if isempty(theLine) || (isnumeric(theLine) && theLine == -1) % EOF
        inBody = 0;
        continue;
    else   
        iStim = iStim + 1;
        foo = textscan(theLine,'%s','delimiter','\t'); % get all the values
%         paramVals = foo{1};
        for i = 1:length(paramFields)
            if evalFlag && ~ismember(paramFields{i},noEval)
                [paramVals{i}, ok] = str2num(foo{1}{i});
                if ~ok
                    paramVals{i} = foo{1}{i};
                    % CS 9/27/2024 - include header parameters in the
                    % sentence info, but allow each sentence to override by
                    % including the same Param name as a column. The entry
                    % '-' is special and means to use the value from <head>
                    if strcmp(paramVals{i},'-')
                        try
                            paramVals{i} = headParams.(paramFields{i});
                        end
                    end
                end
            else
                paramVals{i} = foo{1}{i};

                % same as above. Handle the '-' option
                if strcmp(paramVals{i},'-')
                    try
                        paramVals{i} = headParams.(paramFields{i});
                    end
                end
            end

            stimParams(iStim).(paramFields{i}) = paramVals{i}; % add values to the param struct
        end
    end
end

    
    
    
    
    