function [outSeq, tInfo, allIDs] = parse_stimsequence(inSeq,nLines)
% function outSeq = parse_stimsequence(inSeq,nLines)
% 
% A function to parse stimulus sequences for word strings, matrix
% sentences, etc. 
%
% inSeq is a string with any number of the following tokens:
%   r(x)[y]    "Random" where x and y are numeric arrays
%   o(x)[y]    "Ordered"
%   f(x)[y]    "Fixed"
%
% nLines is the number of desired lines in the output sequence (default 1)
%
% for each line in the output sequence (think of these as "trials"), this
% function will return a sequence of ID numbers corresponding to items
% (words or sentences) that appear in a "stimlist" file. The ID numbers
% will be selected from the [y] arguments appearing within each token:
% 
%   r   elements of y will be selected at random
%   o   the elements of y will be selected in the order they appear, across
%       repeats (x) and lines
%   f   an element of y will be selected at random for each line, but
%           repeated (x) times
% 
%   (x) indicates the number of times a token's function should be
%   repeated, i.e. 'r(2)[1:3]' is equivalent to 'r(1)[1:3] r(1)[1:3]'
% 
%   When (x) has length>1, its value will be selected at random on each
%   line  'r(2:4)[1:10]' will include between 2 and 4 items with ID 1..10
% 
%   Omitting (x) is equivalent to '(1)', i.e., default is one repeat
% 
%   Examples:
% 
%   r[1:4] 5 r[6:7]   play a random ID 1..4, then ID 5, then random ID 6..7
%           -> 3 5 7
%   r(3)[1:4] 5 r[6:7]   play three random IDs 1..4, then ID 5, then random ID 6..7
%           -> 2 1 5 6
%   r(1:3)[1:4] 5 r[6:7]   play one to three random IDs 1..4, then ID 5, then random ID 6..7
%           -> 1 4 3 5 7
% 
%   o[1:2] 3 r[4:5]  play ID 1, then ID 3, then random ID 4..5. On line 2,
%                           play ID 2, ID 3, random 4..5
%           -> 1 3 4
%           -> 2 3 4
%           -> 1 3 5 etc
% 
%   o(2)[1:4] 10    play IDs 1..4 in order, 2 per line, followed by ID 10. 
%           -> 1 2 10
%           -> 3 4 10
% 
%   f(5)[1:4] 10    select random ID 1..4, repeat it five times, then play ID 10
%           -> 2 2 2 2 2 10
%           -> 4 4 4 4 4 10
%   f(2:5)[1:4] 10  same but repeat the ID between 2 and five times
%           -> 1 1 10
%           -> 4 4 4 10
%           -> 2 2 2 2 2 10
%           -> 3 3 3 3 10  etc
%
%
% Author: Chris Stecker (c) 2024 Auditory Space, LLC
 


% the following works, but breaks on whitespace inside brackets
% foo = textscan(inSeq,'%s');
% token = foo{1};
% tInfo = struct;
% 
% for i = 1:length(token)
%     tInfo(i).type = token{i}(1);
%     tInfo(i).IDrange = str2num(tInfo(i).type) ;% just a digit
% 
%     if ~isempty(tInfo(i).IDrange)
%         tInfo(i).type = 'c';
%     else
%         p = [find(token{i}=='(') find(token{i}==')')];
%         if ~isempty(p)
%             if length(p)<2, error(['Malformed sequence string. Could not match parens for token <' type '>']);
%             else
%                 tInfo(i).repeatRange = str2num(token{i}(p(1)+1:p(2)-1));
%             end
%         end
% 
%         s = [find(token{i}=='[') find(token{i}==']')];
%         if ~isempty(s)
%             if length(s)<2, error(['Malformed sequence string. Could not match brackets for token <' type '>']);
%             else
%                 tInfo(i).IDRange = str2num(token{i}(s(1)+1:s(2)-1));
%             end
%         end
%     end
% end
% 
% outSeq = tInfo;

if nargin<2 || isempty(nLines)
    nLines = 1;
end

tokenDex = 0;
tempSeq = inSeq;
tInfo = struct('type','','repeatRange',[],'IDRange',[]);

while tempSeq
    theToken = tempSeq(1);
    tempSeq = tempSeq(2:end);

    if ~isempty(str2num(theToken)) % it's a digit, keep reading to its end
        done = 0;
        while ~done
            if isempty(tempSeq)
                done = 1;
                continue
            end
            theToken(end+1) = tempSeq(1);
            tempSeq = tempSeq(2:end);
            if theToken(end) == ' '
                done = 1;
                theToken = theToken(1:end-1);
            end
        end
        tokenDex = tokenDex+1;
        tInfo(tokenDex).type = 'c';
        tInfo(tokenDex).IDRange = str2num(theToken);

    elseif ismember(theToken,{'r' 'o' 'f'}) % will have [] and maybe ()
        done = 0;
        while ~done
            theToken(end+1) = tempSeq(1);
            tempSeq = tempSeq(2:end);
            if theToken(end) == ']'
                done = 1;
            end
        end
        tokenDex = tokenDex+1;
        tInfo(tokenDex) = readToken(theToken);

    elseif ismember(theToken,{'g' 'n'}) % will have ()
        done = 0;
        while ~done
            theToken(end+1) = tempSeq(1);
            tempSeq = tempSeq(2:end);
            if theToken(end) == ')'
                done = 1;
            end
        end
        tokenDex = tokenDex+1;
        tInfo(tokenDex) = readToken(theToken); 
    elseif theToken==' ' % discard whitespace outside of brackets
        % do nothing
    end
end

allIDs = unique(cat(2,tInfo.IDRange));
outSeq = createOutput(tInfo,nLines);

end

%%%--------==========================-------------
function tInfo = readToken(token)
        tInfo.type = token(1);
        
        
        s = [find(token=='[') find(token==']')];
        if isempty(s)
            tInfo.IDRange = [];
        else
            if length(s)<2, error(['Malformed sequence string. Could not match brackets.']);
            else
                tInfo.IDRange = str2num(token(s(1)+1:s(2)-1));
            end
            token = token([1:s(1)-1 s(2)+1:end]); % remove ID segment before parsing repeats
        end

        p = [find(token=='(') find(token==')')];
        if isempty(p)
            tInfo.repeatRange = [];
        else
            if length(p)<2, error(['Malformed sequence string. Could not match parens.']);
            else
                tInfo.repeatRange = str2num(token(p(1)+1:p(2)-1));
            end
        end


end

%%%--------==========================-------------
function outSeq = createOutput(tInfo,lines)

outSeq = {};
for i = 1:lines
    theStr = '';
    for j = 1:length(tInfo)
        t = tInfo(j);

        if isempty(t.repeatRange)
            nReps = 1;
        else
            nReps = t.repeatRange(randi(length(t.repeatRange)));
        end

        switch(t.type)
            case 'c'
                % a fixed value
                theStr = [theStr num2str(t.IDRange) ' '];
            case 'r'
                % choose values randomly
                for r = 1:nReps
                    nextID = t.IDRange(randi(length(t.IDRange)));
                    theStr = [theStr num2str(nextID) ' '];
                end
            case 'o'
                % choose values in order
                for r = 1:nReps
                    nextID = tInfo(j).IDRange(1); % use tInfo bc this is destructive (keep order for subsequent calls)
                    theStr = [theStr num2str(nextID) ' '];
                    tInfo(j).IDRange = tInfo(j).IDRange([2:end 1]); % cycle around
                end
            case 'f'
                % choose a random value and repeat it 
                nextID = t.IDRange(randi(length(t.IDRange)));
                for r = 1:nReps
                    theStr = [theStr num2str(nextID) ' '];
                end
            case 'g'
                % indicates a gap
                theStr = [theStr 'g' num2str(nReps) ' '];
            case 'n'
                % indicates a noise
                theStr = [theStr 'n' num2str(nReps) ' '];

        end
    end

    outSeq{i} = theStr(1:end-1); %remove final space;
end

end

