function s = fill_tags(s,p)
% s = fill_tags(s,p)
%
% fill the s.tags structure with tags from presenter object p

pt = get(p,'partags');
s.tags = cell2struct(cell(size(pt)),pt,2);

for i=1:length(pt)
    s.tags.(pt{i}) = get_tag_val(p,pt{i});
end