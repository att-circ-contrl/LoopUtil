function [ threshlow threshhigh midval ] = ...
  nlProc_getOutlierThresholdsQuota( dataseries, percbase, percmult, ...
    quotacount )

% function [ threshlow threshhigh midval ] = ...
%   nlProc_getOutlierThresholdsQuota( dataseries, percbase, percmult, ...
%     quotacount )
%
% This function computes low and high threshold for outliers based on
% distance from the median, and adjusts those thresholds to pass at most
% the requested number of elements.
%
% This tolerates multidimensional input.
%
% "dataseries" is a vector or matrix containing samples to process.
% "percbase" [ low high ] gives the percentiles from which the upper and
%   lower thresholds are derived (e.g. [ 25 75 ] for quartiles ).
% "percmult" [ low high ] gives multipliers for generating outlier thresholds.
%   The distance from the median to the upper/lower percentile value is
%   multiplied by this amount. For quartiles, a multipler of 3 gives 2 sigma.
% "quotacount" [ low high ] gives the maximum number of elements that should
%   be detected past the high or low thresholds. If these are positive
%   values less than 1, they're treated as exponents (i.e. 0.5 means the
%   square root of the total number of elements). Values of NaN ignore quota
%   for the relevant thresholds.
%
% "threshlow" is the low outlier threshold.
% "threshhigh" is the high outlier threshold.
% "midval" is the median.


% Tolerate multidimensional arrays.
dataseries = reshape( dataseries, [ 1 numel(dataseries) ] );


% Figure out quota targets.
% NaN comparisons always return false.

totalcount = numel(dataseries);

quota_low = quotacount(1);

if quota_low <= 0
  quota_low = NaN;
elseif quota_low < 1
  quota_low = totalcount ^ quota_low;
end

quota_high = quotacount(2);

if quota_high <= 0
  quota_high = NaN;
elseif quota_high < 1
  quota_high = totalcount ^ quota_high;
end



% Get thresholds from ordinary percentile targets.

[ threshlow threshhigh midval ] = nlProc_getOutlierThresholds( ...
  dataseries, percbase(1), percbase(2), percmult(1), percmult(2) );

% This needs one-dimennsional data.
count_low = sum(dataseries <= threshlow);
count_high = sum(dataseries >= threshhigh);



% If we have too many results from percentile thresholds, get thresholds
% derived from the quotas.

if (~isnan(quota_low)) && (count_low > quota_low)
  prc_low = 100 * quota_low / totalcount;

  if prc_low < 0
    prc_low = 0;
  elseif prc_low > 100
    prc_low = 100;
  end

  % This needs one-dimennsional data.
  threshlow = prctile( dataseries, prc_low );
end

if (~isnan(quota_high)) && (count_high > quota_high)
  prc_high = 100 - ( 100 * quota_high / totalcount );

  if prc_high < 0
    prc_high = 0;
  elseif prc_high > 100
    prc_high = 100;
  end

  % This needs one-dimennsional data.
  threshhigh = prctile( dataseries, prc_high );
end



% Done.
end


%
% This is the end of the file.
