function newflags = ...
  nlProc_erodeBooleanTime( oldflags, samprate, erodebefore, erodeafter )

% function newflags = ...
%   nlProc_erodeBooleanTime( oldflags, samprate, erodebefore, erodeafter )
%
% This processes a vector of boolean values, eroding "true" flags (extending
% "false" flags) forwards and backwards in time by the specified durations.
% Samples up to "erodebefore" at the start of and "erodeafter" at the end of
% sequences of true samples in the original signal are false in the returned
% signal.
%
% Erosion is implemented as dilation of the complement vector with "before"
% and "after" values swapped.
%
% "oldflags" is the boolean vector to process.
% "samprate" is the sampling rate of the flag vector.
% "erodebefore" is the duration in seconds at the start of a sequence to
%   squash.
% "erodeafter" is the duration in seconds at the end of a sequence to squash.
%
% "newflags" is the boolean vector with erosion performed.


% Wrap the sample-based version.

newflags = oldflags;

if (0 < length(oldflags))

  beforecount = round(erodebefore * samprate);
  aftercount = round(erodeafter * samprate);
  newflags = nlProc_erodeBooleanCount( oldflags, beforecount, aftercount );

end


% Done.

end


%
% This is the end of the file.
