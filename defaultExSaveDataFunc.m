function ex = defaultSaveDataFunc(ex,varargin)
% function ex = defaultSaveDataFunc(ex,varargin)
%
% This is the default function to be called by goSaveData(ex). It prompts
% the user for a mat file name (using a file broser dialog) and saves ex
% into that mat file. 
%
% If you'd like different data-saving behavior, write a new function that  
% does it, and use that (by setting ex.saveDataFunc to that function's 
% handle) instead.
%
% returns the name of the save data file in myfile

if nargin>1
    savename = varargin{1};
    if nargin>2 && strcmp(varargin{2},'autosave')
        myfile = savename;
        fname = savename;
    else  
        [fname path] = uiputfile(savename,'Save mat file as...');
        myfile = fullfile(path,fname);
    end
else
    [fname path] = uiputfile('*.mat','Save mat file as...');
        myfile = fullfile(path,fname);

end

if fname
fprintf('Saving to %s\n',myfile);

save(myfile,'ex');
end