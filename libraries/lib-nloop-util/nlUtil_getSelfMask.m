function selfmask = nlUtil_getSelfMask( firstlabels, secondlabels )

% function selfmask = nlUtil_getSelfMask( firstlabels, secondlabels )
%
% This builds a mask that's true for self-comparisons and false otherwise.
% This is intended to be used with channel labels, but will work with any
% list of text labels.
%
% "firstlabels" is a cell array containing the first set of channel labels.
% "secondlabels" is a cell array containing the second set of channel labels.
%
% "selfmask" is a matrix indexed by (firstidx,secondidx) that's true for
%   self-comparisons and false otherwise.


firstcount = length(firstlabels);
secondcount = length(secondlabels);

selfmask = false([ firstcount secondcount ]);

for firstidx = 1:firstcount
  thisfirst = firstlabels{firstidx};
  selfmask(firstidx,:) = strcmp( thisfirst, secondlabels );
end


% Done.
end


%
% This is the end of the file.
