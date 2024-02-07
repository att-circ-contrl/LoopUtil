function [ meandelta driftppm jitterdev polycoeffs residue outmask ] = ...
  nlProc_getTimingStats( firsttimes, secondtimes, polyorder, ...
  outlierwindow, outliersigma )

% function [ meandelta driftppm jitterdev polycoeffs residue outmask ] = ...
%   nlProc_getTimingStats( firsttimes, secondtimes, polyorder,
%     outlierwindow, outliersigma )
%
% This compares two time series and calculates statistics about their
% drift and jitter. The time series are assumed to correspond to each other.
%
% "firstimes" is the first time series to compare.
% "secondtimes" is the second time series to compare.
% "polyorder" is the order to use when doing a polynomial fit of the time
%   difference. This is normally 1 (capturing drift), but higher order fits
%   can capture bowing.
% "outlierwindow" is the time window duration for rejecting outliers during
%   curve fitting, or NaN to fit with outliers.
% "outliersigma" is the number of standard deviations needed for a sample to
%   be considered an outlier, or NaN to keep outliers.
%
% "meandelta" is the average time difference.
% "driftppm" is the absolute value of the slope of a line fit to the time
%   difference, in parts per million.
% "jitterdev" is the standard deviation of the residue after curve-fitting.
% "polycoeffs" is a vector of polynomial coefficients returned by "polyfit"
%   after curve-fitting the time difference.
% "residue" is a vector containing the residue after subtracting the time
%   difference curve fit from the time difference.
% "outmask" is a vector with the same size as "residue" that's true for
%   samples that were considered outliers for curve fitting and false for
%   samples used for the curve fit.


meandelta = NaN;
driftppm = NaN;
jitterdev = NaN;
polycoeffs = [];
residue = NaN(size(firsttimes));

want_remove_outliers = false;
if exist('outliersigma', 'var')
  want_remove_outliers = (~isnan(outlierwindow)) & (~isnan(outliersigma));
end


sampcount = min( length(firsttimes), length(secondtimes) );

if sampcount > 0
  firsttimes = firsttimes(1:sampcount);
  secondtimes = secondtimes(1:sampcount);

  difftimes = secondtimes - firsttimes;


  % Get a filtered version for curve fitting if requested.

  difftimesfilt = difftimes;
  reftimesfilt = firsttimes;
  keepmask = true(size(difftimes));

  if want_remove_outliers
    % Do this with percentiles. 1 sigma is about 1.5x one quartile distance.
    difftimesfilt = nlProc_squashOutliersSlidingWindow( ...
      firsttimes, difftimesfilt, outlierwindow, 25, 1.5 * outliersigma );

    keepmask = ~isnan(difftimesfilt);
    difftimesfilt = difftimesfilt(keepmask);
    reftimesfilt = reftimesfilt(keepmask);
  end

  outmask = ~keepmask;


  % Average time difference.
  meandelta = mean(difftimesfilt);

  % Slope of the time difference, converted to ppm (absolute value).
  scratch = polyfit(reftimesfilt, difftimesfilt, 1);
  driftppm = scratch(1);
  driftppm = abs(driftppm) * 1e6;

  % Do the fit with respect to the filtered list, but get the residue with
  % respect to the full list.
  polycoeffs = polyfit(reftimesfilt, difftimesfilt, polyorder);
  residue = difftimes - polyval(polycoeffs, firsttimes);
  jitterdev = std(residue);
end


% Done.
end


%
% This is the end of the file.
