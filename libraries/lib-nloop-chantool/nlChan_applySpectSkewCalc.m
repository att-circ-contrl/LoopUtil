function [ spectfreqs spectmedian spectiqr spectskew ] = ...
  nlChan_applySpectSkewCalc( wavedata, samprate, tuningparams, perclist )

% function [ spectfreqs spectmedian spectiqr spectskew ] = ...
%   nlChan_applySpectSkewCalc( wavedata, samprate, tuningparams, perclist )
%
% This calls nlProc_calcSpectrumSkew() to compute a persistence spectrum for
% the specified series and to compute statistics and skew for each frequency
% bin.
%
% "wavedata" is the waveform to process.
% "samprate" is the sampling rate.
% "tuningparams" is a structure containing tuning parameters for persistence
%   spectrum generation.
% "perclist" is an array of percentile values that define the tails for
%   skew calculation, per nlProc_calcSkewPercentile().
%
% "spectfreqs" is an array of bin center frequencies.
% "spectmedian" is an array of per-frequency median power values.
% "spectiqr" is an array of per-frequency power interquartile ranges.
% "spectskew" is a cell array, with one cell per "perclist" value. Each cell
%   contains an array of per-frequency skew values.


% Wrap the real function for this.

[ spectfreqs spectmedian spectiqr spectskew ] = ...
  nlProc_calcSpectrumSkew( wavedata, samprate, ...
    [ tuningparams.freqlow tuningparams.freqhigh ], ...
    tuningparams.freqsperdecade, ...
    tuningparams.winsecs, tuningparams.winsteps, ...
    perclist );


%
% Done.

end


%
% This is the end of the file.
