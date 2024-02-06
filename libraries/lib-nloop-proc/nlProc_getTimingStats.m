function [ meandelta driftppm jitterdev polycoeffs residue ] = ...
  nlProc_getTimingStats( firsttimes, secondtimes, polyorder )

% function [ meandelta driftppm jitterdev polycoeffs residue ] = ...
%   nlProc_getTimingStats( firsttimes, secondtimes, polyorder )
%
% This compares two time series and calculates statistics about their
% drift and jitter. The time series are assumed to correspond to each other.
%
% "firstimes" is the first time series to compare.
% "secondtimes" is the second time series to compare.
% "polyorder" is the order to use when doing a polynomial fit of the time
%   difference. This is normally 1 (capturing drift), but higher order fits
%   can capture bowing.
%
% "meandelta" is the average time difference.
% "driftppm" is the absolute value of the slope of a line fit to the time
%   difference, in parts per million.
% "jitterdev" is the standard deviation of the residue after curve-fitting.
% "polycoeffs" is a vector of polynomial coefficients returned by "polyfit"
%   after curve-fitting the time difference.
% "residue" is a vector containing the residue after subtracting the time
%   difference curve fit from the time difference.


meandelta = NaN;
driftppm = NaN;
jitterdev = NaN;
polycoeffs = [];
residue = NaN(size(firsttimes));


sampcount = min( length(firsttimes), length(secondtimes) );

if sampcount > 0
  firsttimes = firsttimes(1:sampcount);
  secondtimes = secondtimes(1:sampcount);

  difftimes = secondtimes - firsttimes;

  % Average time difference.
  meandelta = mean(difftimes);

  % Slope of the time difference, converted to ppm (absolute value).
  scratch = polyfit(firsttimes, difftimes, 1);
  driftppm = scratch(1);
  driftppm = abs(driftppm) * 1e6;

  polycoeffs = polyfit(firsttimes, difftimes, polyorder);
  residue = difftimes - polyval(polycoeffs, firsttimes);
  jitterdev = std(residue);
end


% Done.
end


%
% This is the end of the file.
