function pairmask = nlUtil_getPairMask( firstlabels, secondlabels )

% function pairmask = nlUtil_getPairMask( firstlabels, secondlabels )
%
% This builds a mask that's true exactly once for each pair that isn't a
% self-comparison (removing permutations).
%
% "firstlabels" is a cell array containing the first set of channel labels.
% "secondlabels" is a cell array containing the second set of channel labels.
%
% "pairmask" is a matrix indexed by (firstidx,secondidx) that's true exactly
%   once for each pair (no self-comparisons or permutations).


firstcount = length(firstlabels);
secondcount = length(secondlabels);

pairmask = false(firstcount,secondcount);


for firstidx = 1:firstcount
  thisfirst = firstlabels{firstidx};
  firstsecondidx = find(strcmp( thisfirst, secondlabels ));

  if isempty(firstsecondidx)

    % This label doesn't appear in the second-label list, so all comparisons
    % with it are valid.
    pairmask(firstidx,:) = true;

  else

    % Check for self-comparisons and duplicate pairs.
    for secondidx = 1:secondcount
      thissecond = secondlabels{secondidx};
      secondfirstidx = find(strcmp( thissecond, firstlabels ));

      if isempty(secondfirstidx)
        % This label doesn't appear in the first-label list, so comparisons
        % with it are valid.
        pairmask(firstidx,secondidx) = true;
      elseif ~strcmp(thisfirst, thissecond)
        % This isn't a self-comparison.
        % Accept this if and only if we haven't seen the swapped version.
        pairmask(firstidx,secondidx) = ...
          ~pairmask(secondfirstidx, firstsecondidx);
      end
    end

  end
end


% Done.
end


%
% This is the end of the file.
