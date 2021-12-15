function newseries = ...
  nlProc_trimEndpointsTime( oldseries, samprate, trimstart, trimend )

% function newseries = ...
%   nlProc_trimEndpointsTime( oldseries, samprate, trimstart, trimend )
%
% This crops the specified durations from the start and end of the supplied
% signal.
%
% "oldseries" is the series to process.
% "samprate" is the sampling rate of the input signal.
% "trimstart" is the number of seconds to remove from the beginning.
% "trimend" is the number of seconds to remove from the end.
%
% "newseries" is a truncated version of the input signal.


newseries = oldseries;

if (0 < length(oldseries))

  trimstart = round(trimstart * samprate);
  trimend = round(trimend * samprate);

  newseries = nlProc_trimEndpointsCount( oldseries, trimstart, trimend );

end


%
% Done.

end


%
% This is the end of the file.
