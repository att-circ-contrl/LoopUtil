function peakidx = nlProc_findPeakLargest( dataseries )

% function peakidx = nlProc_findPeakLargest( dataseries )
%
% This finds the sample index of the largest peak in the supplied data
% series.
%
% This finds the peak with the largest magnitude (ignoring sign and complex
% phase angle).
%
% "dataseries" is a vector to search.
%
% "peakidx" is the sample number of the sample in "dataseries" with the
%   largest magnitude, or NaN for empty input.


% Tolerate the "empty data" case.
peakidx = NaN;

if ~isempty(dataseries)
  magvals = abs(dataseries);
  [ magvals, sortidx ] = sort(magvals);

  % Change ascending order to descending order.
  sortidx = flip(sortidx);

  peakidx = sortidx(1);
end


% Done.
end


%
% This is the end of the file.
