function [ mintime maxtime threshlow threshhigh threshmedian ] = ...
  nlProc_getOutlierTimeRange( timeseries, dataseries, ...
    searchrange, statrange, lowperc, highperc, lowmult, highmult )

% function [ mintime maxtime threshlow threshhigh threshmedian ] = ...
%   nlProc_getOutlierTimeRange( timeseries, dataseries, ...
%     searchrange, statrange, lowperc, highperc, lowmult, highmult )
%
% This returns the earliest and latest times at which excursions in a signal
% occur. Excursion thresholds are based on distance from the median.
%
% "timeseries" is a vector containing sample timestamps.
% "dataseries" is a vector containing sample data values.
% "searchrange" [ min max ] specifies the time span over which to look for
%   outliers, or [] to search the entire input.
% "statrange" [ min max ] specifies the time span over which to compute
%   median and percentile statistics for thresholding, or [] to compute them
%   over the entire input.
% "lowperc" is the percentile from which the lower threshold is derived
%   (e.g. 25 for the lower quartile).
% "highperc" is the percentile from which the upper threshold is derived
%   (e.g. 75 for the upper quartile).
% "lowmult" is a multiplier for generating the lower outlier threshold. The
%   distance from the median to the lower percentile value is multiplied by
%   this amount.
% "highmult" is a multiplier for generating the upper outlier threshold. The
%   distance from the median to the upper percentile value is multiplied by
%   this amount.
%
% "mintime" is the earliest time at which excursions were detected, or NaN
%   if no excursions were found.
% "maxtime" is the latest time at which excursions were detected, or NaN if
%   no excursions were found.
% "threshlow" is the low excursion threshold.
% "threshhigh" is the high excursion threshold.
% "threshmedian" is the median value used for computing thresholds.


% Default values if no excursions were found.
mintime = NaN;
maxtime = NaN;

% Default values if we were passed a bad statistics time range.
threshlow = NaN;
threshhigh = NaN;
threshmedian = NaN;


% Get the full time span and fill in search and stat ranges if empty.

firsttime = min(timeseries);
lasttime = max(timeseries);

if isempty(searchrange)
  searchrange = [ firsttime lasttime ];
end

if isempty(statrange)
  statrange = [ firsttime lasttime ];
end


% Get thresholds.

thismask = (timeseries >= min(statrange)) & (timeseries <= max(statrange));
if any(thismask)
  [ threshlow threshhigh threshmedian ] = nlProc_getOutlierThresholds( ...
    dataseries(thismask), lowperc, highperc, lowmult, highmult );
end


% Detect the outlier span and clamp it to the search span.
% NaN thresholds always return false from comparisons, which is ok.

thismask = (dataseries >= threshhigh) | (dataseries <= threshlow);
thismask = thismask & (timeseries >= min(searchrange)) ...
  & (timeseries <= max(searchrange));
if any(thismask)
  scratch = timeseries(thismask);
  mintime = min(scratch);
  maxtime = max(scratch);
end


% Done.
end


%
% This is the end of the file.
