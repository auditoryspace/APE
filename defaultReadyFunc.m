function s = defaultReadyFunc(s,p)
% function s = defaultReadyFunc(s,p)
%
% default readyFunc for stim objects. readyFunc must take a stim object <s>
% and a presenter object <p>. It must set tag vals and/or upload stim data 
% to the <p> in preparation for calling presentFunct. In this case, each 
% parameter tag specified in s.tags is set on the presenter object using
% set_tag_val
%
% invoked by s = goReadyFunc(s,p);

% first, obtain all the tag names which will be set (makeStimFunc should make
% sure only those tags we really want to set are included in s.tags)

tagNames = get(s,'tagnames');

for iTag = 1:length(tagNames)
    tagName = tagNames{iTag};
    tagVal = get(s,'tags',tagNames{iTag});
    if length(tagName)>6 & tagName(1:6) == 'atten_'
        atten_num = str2num(tagName(7:end));
        p = set_atten(p,atten_num,tagVal);
    else
        p = set_tag_val(p,tagName,tagVal);
    end
end

