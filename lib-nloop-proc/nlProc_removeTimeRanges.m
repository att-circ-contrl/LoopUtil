function newseries = ...
  nlProc_removeTimeRanges( oldseries, samprate, trimtimes )

% function newseries = ...
%   nlProc_removeTimeRanges( oldseries, samprate, trimtimes )
%
% This NaNs out specified regions of the input signal.
%
% "oldseries" is the series to process.
% "samprate" is the sampling rate of the input signal.
% "trimtimes" is a cell array containing time spans to NaN out. Time spans
%   have the form "[ time1 time2 ]", where times are in seconds. Negative
%   times are relative to the end of the signal, positive times are relative
%   to the start of the signal (both start at 0 seconds). Use a very small
%   negative value for "-0".
%
% "newseries" is a modified version of the input series with the specified
%   time ranges set to NaN.

newseries = oldseries;

for ridx = 1:length(trimtimes)

  thisrange = trimtimes{ridx};

  for tidx = 1:length(thisrange)
    thistime = thisrange(tidx);

    if 0 > thistime
      thistime = length(newseries) + round(samprate * thistime);
    else
      thistime = 1 + round(samprate * thistime);
    end

    thistime = max(1, thistime);
    thistime = min(length(newseries), thistime);

    thisrange(tidx) = thistime;
  end

  newseries(min(thisrange):max(thisrange)) = NaN;

end


%
% Done.

end


%
% This is the end of the file.
