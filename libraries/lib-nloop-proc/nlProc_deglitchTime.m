function newseries = ...
  nlProc_deglitchTime( oldseries, samprate, glitchtime, dropouttime)

% function newseries = ...
%   nlProc_deglitchTime( oldseries, samprate, glitchtime, dropouttime)
%
% This function removes spurious gaps (drop-outs) and brief events (glitches)
% from a one-dimensional boolean vector.
%
% This version of the function specifies durations in seconds.
%
% "oldseries" is a logical vector to process.
% "samprate" is the sampling rate of the input signal.
% "glitchtime" is the longest event duration to reject as spurious.
% "dropouttime" is the longest gap duration to reject as spurious.
%
% "newseries" is a modified version of "oldseries".


% Wrap the sample-based function.
% This handles rounding and bulletproofing, so we don't need to here.

newseries = nlProc_deglitchCount( ...
  oldseries, glitchtime * samprate, dropouttime * samprate );


% Done.
end


%
% This is the end of the file.
