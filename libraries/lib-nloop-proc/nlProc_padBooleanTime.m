function newflags = ...
  nlProc_padBooleanTime( oldflags, samprate, padbefore, padafter )

% function newflags = ...
%   nlProc_padBooleanTime( oldflags, samprate, padbefore, padafter )
%
% This processes a vector of boolean values, extending "true" flags
% forwards and backwards in time by the specified durations. Samples
% up to "padbefore" ahead of and "padafter" following true samples in the
% original signal are true in the returned signal.
%
% This is a dilation operation. To perform erosion, perform dilation on the
% complement of a vector (i.e.  newflags = ~ padBooleanTime( ~ oldflags )).
% Remember to swap "before" and "after" for the complement vector.
%
% "oldflags" is the boolean vector to process.
% "samprate" is the sampling rate of the flag vector.
% "padbefore" is the duration in seconds backwards in time to pad.
% "padafter" is the duration in seconds forwards in time to pad.
%
% "newflags" is the boolean vector with padding performed.


% Wrap the sample-based version.

newflags = oldflags;

if (0 < length(oldflags))

  beforecount = round(padbefore * samprate);
  aftercount = round(padafter * samprate);
  newflags = nlProc_padBooleanCount( oldflags, beforecount, aftercount );

end


% Done.

end


%
% This is the end of the file.
