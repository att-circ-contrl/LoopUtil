function newflags = ...
  nlProc_erodeBooleanCount( oldflags, erodebefore, erodeafter )

% function newflags = ...
%   nlProc_erodeBooleanCount( oldflags, erodebefore, erodeafter )
%
% This processes a vector of boolean values, eroding "true" flags (extending
% "false" flags) forwards and backwards in time by the specified number of
% samples. Samples up to "erodebefore" at the start of and "erodeafter"
% at the end of sequences of true samples in the original signal are false
% in the returned signal.
%
% Erosion is implemented as dilation of the complement vector with "before"
% and "after" values swapped.
%
% "oldflags" is the boolean vector to process.
% "erodebefore" is the number of samples at the start of a sequence to squash.
% "erodeafter" is the number of samples at the end of a sequence to squash.
%
% "newflags" is the boolean vector with erosion performed.


% Force sanity.

oldflags = (oldflags > 0.5);


% Wrap the dilation operation.

newflags = oldflags;

if (0 < length(oldflags))
  % Remember to swap "before" and "after" for the complement vector.
  newflags = ~ nlProc_padBooleanCount(~oldflags, erodeafter, erodebefore);
end


% Done.

end


%
% This is the end of the file.
