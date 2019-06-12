function play_local(s)
% play_local(s)
%
% use matlab soundsc to play a stim's wave forms (stored in s.tags.ToneL and
% s.tags.ToneR) at the samprate stored in s.params.samprate

t = get(s,'tags');
if isfield(t,'ToneL')
    soundsc([get(s,'tags','ToneL'); get(s,'tags','ToneR')]',get(s,'params','samprate'));
else
    soundsc([get(s,'tags','SigL'); get(s,'tags','SigR')]',get(s,'params','samprate'));
end