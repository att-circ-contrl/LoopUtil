function [ lfpseries spikeseries ] = nlChan_applyFiltering( ...
  wavedata, samprate, tuningparams );

% function [ lfpseries spikeseries ] = nlChan_applyFiltering( ...
%   wavedata, samprate, tuningparams );
%
% This performs filtering to suppress power line noise, zero-average the
% signal, and to split the signal into LFP and spike components.
%
% Power line noise filtering and DC removal filtering can be suppressed by
% setting their respective filter frequencies to 0 Hz.
%
% "wavedata" is the waveform to process.
% "samprate" is the sampling rate.
% "tuningparams" is a structure containing tuning parameters for filtering.
%
% "newdata" is the series after filtering.


% Wrap the real function for this.

[ lfpseries spikeseries ] = nlProc_filterSignal( wavedata, samprate, ...
  tuningparams.lfprate, tuningparams.lfpcorner, ...
  tuningparams.powerfreq, tuningparams.dcfreq );


%
% Done.

end


%
% This is the end of the file.
