function newdata = nlProc_squashOutliersSlidingWindow( ...
  timeseries, olddata, windowrad, threshperc, threshmult )

% function newdata = nlProc_squashOutliersSlidingWindow( ...
%   timeseries, olddata, windowrad, threshperc, threshmult )
%
% This performs sliding-window outlier rejection. Data elements that are
% too far from the median within the window are replaced with NaN in the
% output.
%
% There must be at least 6 non-NaN data elements in the window for squashing
% to be performed; otherwise all samples are kept.
%
% Typical use cases are "2x the inter-quartile range" (threshperc = 25,
% threshmult = 2.0), "1x the inter-decile range" (threshperc = 10,
% threshmult = 1.0), and "4x the standard deviation" (threshperc = 16,
% threshmult = 4.0).
%
% "timeseries" is a vector of timestamps for the data values being processed.
% "olddata" is a vector containing data values to remove outliers from.
% "windowrad" is the window half-width to use when evaluating statistics.
% "threshperc" is the percentile used when computing the outlier thresholds.
% "threshmult" is a multiplier used when computing the outlier thresholds.
%   The distance from the median to the percentile threshold is multiplied
%   by this factor to get the outlier threshold.
%
% "newdata" is a copy of "olddata" with outlier values replaced with NaN.


% Initialize output.
newdata = olddata;


% Make sure percentiles are in the lower half.
if threshperc >= 50
  threshperc = 100 - threshperc;
end


% Get window boundaries.
% NOTE - Because we're comparing the time series with itself, we'll
% always have valid corresponding windows (no NaN windows).
[ spanstart spanend ] = ...
  nlProc_getSlidingWindowIndices( timeseries, timeseries, windowrad );


% Walk through the list of samples.
for sidx = 1:length(newdata)
  thisval = newdata(sidx);
  if ~isnan(thisval)

    % Get the windowed list of data.
    % This always contains at least one element (the sample under test).
    thisstart = spanstart(sidx);
    thisend = spanend(sidx);
    windata = olddata(thisstart:thisend);

    % Squash NaNs and proceed if we have enough samples left.
    windata = windata(~isnan(windata));
    if length(windata) >= 6
      [ threshlow threshhigh midval ] = nlProc_getOutlierThresholds( ...
        windata, threshperc, (100 - threshperc), threshmult, threshmult );

      % NOTE - Using > and <, not >= and <=, to handle the pathological
      % case where values are nearly-constant, resulting in very close
      % thresholds.
      if (thisval > threshhigh) || (thisval < threshlow)
        newdata(sidx) = NaN;
      end
    end

  end
end


% Done.

end


%
% This is the end of the file.
