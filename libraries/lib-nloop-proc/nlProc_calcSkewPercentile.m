function [ seriesmedian seriesiqr seriesskew rawpercentiles ] = ...
  nlProc_calcSkewPercentile(dataseries, tailpercent)

% function [ seriesmedian seriesiqr seriesskew rawpercentiles ] = ...
%   nlProc_calcSkewPercentile(dataseries, tailpercent)
%
% This computes the median and the (tailpercent, 100%-tailpercent) tail
% percentiles for the specified series, and evaluates skew by comparing the
% midsummary (average of the tail values) with the median. The result is
% normalized (a skew of +/- 1 is a displacement by +/- the interquartile
% range).
%
% "dataseries" is the sample sequence to process.
% "tailpercent" is an array of tail values to test.
%
% "seriesmedian" is the series median value.
% "seriesiqr" is the series interquartile range.
% "seriesskew" is an array of normalized skew values corresponding to the
%   tail percentages.
% "rawpercentiles" is an array with the actual percentile values used for
%   skew calculations. It contains percentile values corresponding to
%   [ (tailpercent) (median) (100 - tailpercent) (25%) (75%) ].


% Build the list of percentile values.

percount = length(tailpercent);

percentiletable = tailpercent;
percentiletable(1 + percount) = 50;
percentiletable( (1 + percount +1):(1 + percount + percount) ) = ...
  100 - tailpercent;
percentiletable(1 + length(percentiletable)) = 25;
percentiletable(1 + length(percentiletable)) = 75;


% Get the corresponding percentile values.

percentlist = prctile( dataseries, percentiletable );


% Record median and compute skew for each tail percentile.

rawpercentiles = percentlist;
seriesmedian = percentlist(1 + percount);
seriesiqr = ...
  percentlist(length(percentlist)) - percentlist(length(percentlist) - 1);
seriesiqr = abs(seriesiqr);

seriesskew = [];
medval = seriesmedian;

for pidx = 1:percount

  lowval = percentlist(pidx);
  highval = percentlist(1 + percount + pidx);

  scratch = 0.5 * (lowval + highval);
  seriesskew(pidx) = (scratch - medval) / seriesiqr;

end


%
% Done.

end


%
% This is the end of the file.
