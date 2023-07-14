function edgelist = nlProc_getBinEdgesFromMidpoints( midlist, scaletype )

% function edgelist = nlProc_getBinEdgesFromMidpoints( midlist, scaletype )
%
% This makes reasonable guesses at histogram bin edges given a list of bin
% midpoints.
%
% "midlist" is a vector containing bin midpoint values.
% "scaletype" is 'log' or 'linear'.
%
% "edgelist" is a vector with one more element than "midlist" containing
%   bin edges.


midcount = length(midlist);
edgelist = [ 0 1 ];

if midcount == 1

  edgelist = [ midlist(1) - 1, midlist(1) + 1 ];

elseif midcount > 1

  % Convert to the log domain if necessary.
  % NOTE - Negative or zero input values will give NaNs in the output!
  if strcmp('log', scaletype)
    midlist = log(midlist);
  end

  % Extend the list.
  % Do this by duplicating the step size found at each end.
  midlist(2:(midcount+1)) = midlist(1:midcount);
  midlist(1) = 2 * midlist(2) - midlist(3);
  midlist(midcount+2) = 2 * midlist(midcount+1) - midlist(midcount);

  % Get the average of adjacent midpoints in the extended list.
  edgelist(1:(midcount+1)) = ...
    0.5 * ( midlist(1:(midcount+1)) + midlist(2:(midcount+2)) );

  % Convert back from the log domain if necessary.
  if strcmp('log', scaletype)
    edgelist = exp(edgelist);
  end

end


% Done.
end


%
% This is the end of the file.
