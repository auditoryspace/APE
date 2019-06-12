function r =rboxTellDoneFunc(r,p)
%function r =rboxTellDoneFunc(r,p)
%
% 
% alert the operator and subject that we're done.

% alert the operator first
fprintf('All done.\n');
beep;


% Flash some lights to say "you're finished"
for i = 1:10
        for j = 1:4
            set_tag_val(p,['LED' num2str(j)],rem(i,2));
            pause(0.1);
        end
end

% alert the operator
for i = 1:2, beep; pause(0.8); end
