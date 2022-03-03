function [ dropoutfrac artifactfrac ] = nlCheck_testDropoutsArtifacts( ...
  wavedata, smoothsamps, dropout_threshold, artifact_threshold )

% function [ dropoutfrac artifactfrac ] = nlCheck_testDropoutsArtifacts( ...
%   wavedata, smoothsamps, dropout_threshold, artifact_threshold )
%
% This function computes a rectified version of the input signal, smooths it,
% finds the median amplitude, and looks for samples that are above some
% multiple of the median amplitude or below some fraction of the median
% amplitude.
%
% Samples above the high threshold are assumed to be artifacts, and samples
% below the low threshold are assumed to be drop-outs.
%
% "wavedata" is a vector containing waveform data samples.
% "smoothsamps" is the smoothing window size, in samples. This is
%   approximately one period at the low-pass filter's cutoff frequency.
% "dropout_threshold" is a multiplier determining the lower threshold to test.
%   This should be less than one.
% "artifact_threshold" is a multiplier determining the upper threshold to
%   test. This should be greater than one.
%
% "dropoutfrac" is the fraction of samples that were below the lower
%   threshold.
% "artifactfrac" is the fraction of samples that were above the upper
%   threshold.


dropoutfrac = 0;
artifactfrac = 0;

% We need at least one sample to get the median, at least two to de-trend,
% and at least three to get meaningful output values.
if length(wavedata) >= 3

  % De-trend the data.

  timeseries = 1:length(wavedata);
  lincoeffs = polyfit(timeseries, wavedata, 1);
  wavedata = wavedata - polyval(lincoeffs, timeseries);


  % Rectify and smooth the data.

  % NOTE - We're using "smoothdata" with the "gaussian" method.
  % The documentation doesn't say how the window size relates to the
  % standard deviation, but the filtered example seems to have a corner
  % frequency with period equal to the window size.

% FIXME - High-pass filter before rectifying, to match the original.
wavedata = wavedata - smoothdata( wavedata, 'gaussian', 0.1 * smoothsamps );

  wavedata = abs(wavedata);
  wavedata = smoothdata( wavedata, 'gaussian', smoothsamps );


  % Compute the fraction of samples above and below their respective
  % thresholds.

  medval = median(wavedata);

  thismask = (wavedata < (medval * dropout_threshold));
  dropoutfrac = sum(thismask) / length(thismask);

  thismask = (wavedata > (medval * artifact_threshold));
  artifactfrac = sum(thismask) / length(thismask);

end


% Done.

end


%
% This is the end of the file.
