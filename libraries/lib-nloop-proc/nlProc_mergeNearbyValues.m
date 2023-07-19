function [ newlist newidxfromold oldidxfromnew ] = ...
  nlProc_mergeNearbyValues( oldlist, winsize )

% function [ newlist newidxfromold oldidxfromnew ] = ...
%   nlProc_mergeNearbyValues( oldlist, winsize )
%
% This function merges nearby entries in a list of values, returning a
% smaller list and a lookup table indicating which new value corresponds
% to each old list entry.
%
% FIXME - This uses an O(n2) algorithm!
%
% "oldlist" is a vector containing values to group.
% "winsize" is a scalar indicating the window size for grouping.
%
% "newlist" is a vector containing a sorted list of new values.
% "newidxfromold" is a vector of the same size as "oldlist" that contains the
%   location in "newlist" corresponding to each entry in "oldlist".
% "oldidxfromnew" is a cell array of the same size as "newlist" that contains
%   vectors holding all locations in "oldlist" corresponding values in
%   "newlist".


% Sort the list, but remember the unsorted order.
[ oldlist sortidx ] = sort(oldlist);



% Iteratively group values.

% FIXME - Using an easy algorithm that's O(n2).
% A smarter implementation wouldn't keep redoing the search after pruning.

searchlist = oldlist;
spanmembers = helper_countSpanMembers(searchlist, winsize);
newlist = [];

while ~isempty(spanmembers)
  bestidx = min(find( spanmembers == max(spanmembers) ));

  bestmin = searchlist(bestidx);
  bestmax = bestmin + winsize;

  % Record the bin start times; we'll adjust to midpoints later.
  newlist = [ newlist bestmin ];

  keepmask = (searchlist < bestmin) | (searchlist > bestmax);
  searchlist = searchlist(keepmask);

  % We have to regenerate the list, not just mask the old list.
  % Bins that partly-overlap the removed region would otherwise still have
  % contributions from the removed region.
  spanmembers = helper_countSpanMembers(searchlist, winsize);
end

% Sort the list of new values.
newlist = sort(newlist);



% Build the old-to-new lookup table.
% Since both lists are sorted, this can be done efficiently.

newidx = 1;
newcount = length(newlist);
newidxfromold = [];

for oldidx = 1:length(oldlist)
  % This walks through the list a total of once, so it's O(n) total.
  while (newidx <= newcount) ...
    && ( oldlist(oldidx) > (newlist(newidx) + winsize) )
    newidx = newidx + 1;
  end

  newidxfromold(oldidx) = newidx;
end



% Adjust output values to be bin minpoints rather than starting values.
newlist = newlist + 0.5 * winsize;

% Un-sort the old-to-new lookup table.
unsortidx(sortidx) = 1:length(sortidx);
newidxfromold = newidxfromold(unsortidx);

% Build the new-to-old lookup table now that we have the correct old indices.

oldidxfromnew = cell(size(newlist));

for oldidx = 1:length(newidxfromold)
  newidx = newidxfromold(oldidx);
  % Fresh cells are initialized with [], which is fine.
  oldidxfromnew{newidx} = [ oldidxfromnew{newidx} oldidx ];
end



% Done.
end



%
% Helper Functions


function membercounts = helper_countSpanMembers( datalist, spansize )

  membercounts = ones(size(datalist));

  datacount = length(datalist);
  endidx = 1;

  for didx = 1:datacount
    endval = datalist(didx) + spansize;

    % This sweeps through the list at most once, so it's O(n) total.
    while (endidx <= datacount) && (datalist(didx) <= endidx)
      endidx = endidx + 1;
    end

    % If the present value was the only one in the span, endidx = didx + 1.
    % So we'd want (1 + (endidx - 1) - didx).
    membercounts(didx) = endidx - didx;
  end

end



%
% This is the end of the file.
