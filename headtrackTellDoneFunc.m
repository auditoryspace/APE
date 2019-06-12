function r =headtrackTellDoneFunc(r,p)
%function r =headtrackTellDoneFunc(r,p)
%
% 
% alert the operator and subject that we're done.

% alert the operator first
fprintf('All done.\n');
beep;


% Flash some lights to say "you're finished"
for i = 1:4
        for j = 1:5
            k = j - 1; if k<1, k=5; end
            set_tag_val(p,['LED' num2str(j)],1);
            pause(0.1);
            set_tag_val(p,['LED' num2str(k)],0);
            pause(0.1);
            
        end
end

set_tag_val(p,['LED' num2str(j)],0);


% alert the operator
for i = 1:2, beep; pause(0.8); end
