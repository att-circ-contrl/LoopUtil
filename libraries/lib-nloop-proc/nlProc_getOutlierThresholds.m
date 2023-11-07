function [ threshlow threshhigh midval ] = nlProc_getOutlierThresholds( ...
  dataseries, lowperc, highperc, lowmult, highmult )

% function [ threshlow threshhigh midval ] = nlProc_getOutlierThresholds( ...
%   dataseries, lowperc, highperc, lowmult, highmult )
%
% This function computes low and high thresholds for outliers based on
% distance from the median.
%
% This tolerates multidimensional input.
%
% "dataseries" is a vector or matrix containing samples to process.
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
% "threshlow" is the low outlier threshold.
% "threshhigh" is the high outlier threshold.
% "midval" is the median.

% Tolerate multidimensional arrays.
dataseries = reshape( dataseries, [ 1 numel(dataseries) ] );

percvals = prctile( dataseries, [ lowperc, 50, highperc ] );
lowval = percvals(1);
midval = percvals(2);
highval = percvals(3);

threshlow = midval + (lowval - midval) * lowmult;
threshhigh = midval + (highval - midval) * highmult;


% Done.
end


%
% This is the end of the file.
