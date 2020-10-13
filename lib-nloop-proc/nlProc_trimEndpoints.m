function newseries = ...
  nlProc_trimEndpints( oldseries, samprate, trimstart, trimend )

% function newseries = ...
%   nlProc_trimEndpints( oldseries, samprate, trimstart, trimend )
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

if (0 < length(newseries))

  trimstart = round(trimstart * samprate);
  trimend = round(trimend * samprate);

  if (0 < trimstart)
    trimstart = min( length(newseries) - 1, trimstart );
    newseries = newseries( (trimstart + 1):length(newseries) );
  end

  if (0 < trimend)
    trimend = min( length(newseries) - 1, trimend );
    newseries = newseries( 1:(length(newseries) - trimend) );
  end

end


%
% Done.

end


%
% This is the end of the file.
