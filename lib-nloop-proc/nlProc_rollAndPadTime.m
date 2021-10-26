function newseries = ...
  nlProc_rollAndPadTime( oldseries, samprate, rolltime, padtime )

% function newseries = ...
%   nlProc_rollAndPadTime( oldseries, samprate, rolltime, padtime )
%
% This performs DC and ramp removal, applies a Tukey (cosine) roll-off
% window, and pads the endpoints of the supplied signal.
%
% "oldseries" is the series to process.
% "samprate" is the sampling rate of the input signal.
% "rolltime" is the duration in seconds of the starting and ending roll-offs.
% "padtime" is the duration in seconds of starting and ending padding.
%
% "newseries" is the processed signal.


newseries = oldseries;

if (0 < length(oldseries))

  rollsamps = round(rolltime * samprate);
  padsamps = round(padtime * samprate);

  newseries = nlProc_rollAndPadCount(oldseries, rollsamps, padsamps);

end


% Done.

end


%
% This is the end of the file.
