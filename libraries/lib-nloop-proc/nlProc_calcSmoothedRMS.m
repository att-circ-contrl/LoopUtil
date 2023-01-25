function [ smoothed_rms smoothed_rms_lagged ] = ...
  nlProc_calcSmoothedRMS( wavedata, tausamples )

% function [ smoothed_rms smoothed_rms_lagged ] = ...
%   nlProc_calcSmoothedRMS( wavedata, tausamples )
%
% This computes the square of the input signal, smooths it, and returns
% the square root of the smoothed squared signal.
%
% Smoothing is done by constructing a first-order exponential filter and
% applying it backwards and forwards in time using "filtfilt". This gets
% around some of Matlab's oddities with very-low-frequency filters.
%
% The "lagged" output uses "filter" to apply the exponential filter forwards
% in time only (producing causal output).
%
% "wavedata" is a vector containing the sample series to process.
% "tausamples" is the smoothing time constant in samples.
%
% "smoothed_rms" is the square root of the smoothed squared signal with
%   acausal (bidirectional) filtering.
% "smoothed_rms_lagged" is the square root of the smoothed squared signal
%   with causal (one-direction) filtering.


% Build a first-order exponential filter.

new_samp_weight = 1.0 / tausamples;

bseries = [ new_samp_weight ];
aseries = [ 1, (-(1 - new_samp_weight)) ];


% Square the signal, filter it, and take the square root.

wavedata = wavedata .* wavedata;
smoothed_rms = sqrt( filtfilt( bseries, aseries, wavedata ) );
smoothed_rms_lagged = sqrt( filter( bseries, aseries, wavedata ) );


% Done.
end


%
% This is the end of the file.
