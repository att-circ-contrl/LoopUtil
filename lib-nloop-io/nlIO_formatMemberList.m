function memberstring = ...
  nlIO_formatMemberList( candidates, format, memberflags )

% function memberstring = ...
%   nlIO_formatMemberList( candidates, format, memberflags )
%
% This formats a list of matching candidates in human-readable form, in a
% manner similar to page numbering (e.g. "5-6, 7, 12, 13-15"). Member
% entries that are contiguous in the candidate list are reported as ranges
% rather than as individuals.
%
% The candidate list is assumed to already be sorted in a sensible order.
%
% "candidates" is a vector or cell array containing member labels.
% "format" is a "sprintf" conversion format for turning a candidate label
%   into appropriate human-readable output.
% "memberflags" is a logical vector of the same size as "candidates" that is
%   "true" for candidates that are to be reported and "false" otherwise.
%
% "memberstring" is a human-readable string summarizing the list of
%   candidates for which "memberflags" is true.


memberstring = '';
membercount = length(memberflags);

memberfirst = memberflags;
memberlast = memberflags;
if membercount > 1
  memberfirst(2:membercount) = memberfirst(2:membercount) ...
    & (~ memberflags(1:(membercount-1)) );
  memberlast(1:(membercount-1)) = memberlast(1:(membercount-1)) ...
    & (~ memberflags(2:membercount) );
end


separator = '--';
if iscell(candidates)
  separator = ' to ';
end


for fidx = 1:membercount

  thiscandidate = candidates(fidx);
  if iscell(thiscandidate)
    thiscandidate = thiscandidate{1};
  end

  if memberfirst(fidx)
    if ~isempty(memberstring)
      memberstring = [ memberstring ', ' ];
    end
    memberstring = [ memberstring sprintf(format, thiscandidate) ];
  elseif memberlast(fidx)
    memberstring = [ memberstring separator sprintf(format, thiscandidate) ];
  end

end


% Done.

end


%
% This is the end of the file.
