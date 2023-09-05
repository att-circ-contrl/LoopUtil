function outliervec = nlProc_getOutliers( ...
  dataseries, lowperc, highperc, lowmult, highmult )

% function outliervec = nlProc_getOutliers( ...
%   dataseries, lowperc, highperc, lowmult, highmult )
%
% This function flags outliers in a data series based on their distance from
% the median.
%
% "dataseries" is a vector containing samples to process.
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
% "outliervec" is a boolean vector of the same size as "dataseries" that's
%   true for data samples past the outlier thresholds and false otherwise.


[ thresholow threshhigh midval ] = nlProc_getOutlierThresholds( ...
  dataseries, lowperc, highperc, lowmult, highmult );

outliervec = (dataseries <= threshlow) | (dataseries >= threshhigh);


% Done.
end


%
% This is the end of the file.
