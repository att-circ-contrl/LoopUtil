function peakidx = nlProc_findPeakNearest( datavals, timevals, timetarget )

% function peakidx = nlProc_findPeakNearest( datavals, timevals, timetarget )
%
% This finds the sample index of the peak in the supplied data series that
% is closest to the specified time series location.
%
% Peaks are local maxima of magnitude (ignoring sign and complex phase angle).
%
% "datavals" is a vector with data series values.
% "timevals" is a vector with time series values.
% "timetarget" is the time value to search near. This doesn't have to be
%   present in "timevals" (distance to it is minimized).
%
% "peakidx" is the sample number of the sample in "datavals" which is the
%   magnitude local maximum closest to the specified starting time. If no
%   peaks are found (ramp input or empty input), "peakidx" is NaN.


%
% First pass: Identify peaks.

% We're looking at the first difference of the magnitude.
% This shortens the series by one sample.
% Tolerate nonuniform time sampling.
diffvals = diff(abs(datavals)) ./ diff(timevals);

% Look for positive-to-negative zero-crossings in the derivative to find
% maxima.
% This shortens the series by a second sample.
diffpositive = (diffvals >= 0);
diffcount = length(diffpositive);
peakmask = diffpositive(1:diffcount-1) & ( ~diffpositive(2:diffcount) );

% Truncate the input series to match the new length.
datavals = datavals(2:diffcount+1);
timevals = timevals(2:diffcount+1);

% Get a matching index series.
idxvals = 2:(diffcount+1);

% Convert all of these into sparse series.
datavals = datavals(peakmask);
timevals = timevals(peakmask);
idxvals = idxvals(peakmask);


%
% Second pass: Find the peak closest to the starting time.

% Tolerate the "we found no peaks" case. A ramp will do that.
peakidx = NaN;

if ~isempty(datavals)
  distancevals = abs(timevals - timetarget);
  [ distancevals, sortidx ] = sort(distancevals);
  bestidx = sortidx(1);

  peakidx = idxvals(bestidx);
end


% Done.
end


%
% This is the end of the file.
