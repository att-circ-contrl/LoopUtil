function [ dropoutfrac artifactfrac ] = nlCheck_testFTDropoutsArtifacts( ...
  ftdata, smoothfreq, dropout_threshold, artifact_threshold )

% function [ dropoutfrac artifactfrac ] = nlCheck_testFTDropoutsArtifacts( ...
%   ftdata, smoothfreq, dropout_threshold, artifact_threshold )
%
% This function calls nlCheck_testDropoutsArtifacts() to compute the fraction
% of samples that are dropouts and the fraction of samples that are artifacts
% in each channel and trial in a Field Trip dataset.
%
% This is done by rectifying and smoothing the original signal and then
% thresholding the resulting signal against multiples of the median signal.
% This should be treated as an estimate only; for more accurate artifact and
% dropout detection, use more sophisticated algorithms.
%
% "ftdata" is a ft_datatype_raw structure containing ephys data.
% "smoothfreq" is the low-pass filter corner frequency to use for smoothing
%   the data prior to detection. Artifacts and dropouts shorter than 1/2pi*f
%   will be attenuated.
% "dropout_threshold" is a multiplier determining the lower threshold to test.
%   This should be less than one.
% "artifact_threshold" is a multiplier determining the upper threshold to
%   test. This should be greater than one.
%
% "dropoutfrac" is a cell array with one cell per trial, each containing a
%   Nchans x 1 floating-point vector with fraction of samples that were below
%   the lower threshold.
% "artifactfrac" is a cell array with one cell per trial, each containing a
%   Nchans x 1 floating-point vector with fraction of samples that were above
%   the upper threshold.


% FIXME - We don't have a very accurate smoothing frequency cutoff. The
% smoothing window is _roughly_ one period at the corner frequency. This
% should be good enough for most purposes.

smoothsamps = ftdata.fsample / smoothfreq;

% FIXME - Fudge factor to bring this in line with the old algorithm.
% A shorter smoothing window makes this more sensitive to brief events.
smoothsamps = 0.4 * smoothsamps;


trialcount = length(ftdata.trial);
chancount = length(ftdata.label);

dropoutfrac = {};
artifactfrac = {};

for tidx = 1:trialcount
  thisdropout = zeros(chancount,1);
  thisartifact = zeros(chancount,1);

  for cidx = 1:chancount
    [ singledropout singleartifact ] = nlCheck_testDropoutsArtifacts( ...
      ftdata.trial{tidx}(cidx,:), smoothsamps, ...
      dropout_threshold, artifact_threshold );
    thisdropout(cidx) = singledropout;
    thisartifact(cidx) = singleartifact;
  end

  dropoutfrac{tidx} = thisdropout;
  artifactfrac{tidx} = thisartifact;
end


% Done.

end


%
% This is the end of the file.
