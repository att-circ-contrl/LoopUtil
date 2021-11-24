function resultstats = nlChan_processChannel( wavedata, samprate, ...
  tuningfilt, tuningspect, tuningperc )

% function resultstats = nlChan_processChannel( wavedata, samprate, ...
%   tuningfilt, tuningspect, tuningperc )
%
% This accepts a wideband waveform, performs filtering to split it into
% spike and LFP signals, and calculates various statistics for each of these
% signals.
%
% This is intended to be called by nlChan_iterateChannels() via a wrapper.
%
% "wavedata" is the waveform to process.
% "samprate" is the sampling rate.
% "tuningfilt" is a structure containing tuning parameters for filtering.
% "tuningspect" is a structure containing tuning parameters for persistence
%   spectrum generation.
% "tuningperc" is a structure containing tuning parameters for spike and
%   burst identification via percentile binning.
%
% "resultstats" is a structure containing the following fields:
%   "spikemedian", "spikeiqr", "spikeskew", and "spikepercentvals" are the
%     corresponding fields returned by nlProc_calcSkewPercentile() using the
%     high-pass-filtered spike signal.
%   "spikebincounts" and "spikebinedges" are the the corresponding fields
%     returned by histcounts() using a normalized version of the spike signal.
%   "spectfreqs", "spectmedian", "spectiqr", and "spectskew" are the
%     corresponding fields returned by nlChan_applySpectSkewCalc() using the
%     low-pass-filtered LFP signal.
%   "persistvals", "persistfreqs", and "persistpowers" are the corresponding
%     fields returned by pspectrum() using the LFP signal.


% Filtering and downsampling.

[ lfpseries spikeseries ] = ...
  nlChan_applyFiltering( wavedata, samprate, tuningfilt );

lfprate = tuningfilt.lfprate;


% Get spike statistics.

[ spikemedian spikeiqr spikeskew spikepercentvals ] = ...
  nlProc_calcSkewPercentile(spikeseries, tuningperc.spikerange);

spikebinedges = -20:0.5:20;
[ spikebincounts spikebinedges ] = ...
  histcounts(spikeseries / spikeiqr, spikebinedges);


% Get burst statistics and persistence spectrum.

[ spectfreqs spectmedian spectiqr spectskew ] = ...
  nlChan_applySpectSkewCalc( lfpseries, lfprate, ...
    tuningspect, tuningperc.burstrange );

[ persistvals persistfreqs persistpowers ] = ...
  pspectrum( lfpseries, lfprate, 'persistence', ...
    'Leakage', 0.75, ...
    'FrequencyLimits', [ tuningspect.freqlow tuningspect.freqhigh ], ...
    'TimeResolution', tuningspect.winsecs );


% Build the output structure.
% Remember to wrap cell arrays in {}.

resultstats = struct ( ...
  'spikemedian', spikemedian, 'spikeiqr', spikeiqr, ...
  'spikeskew', spikeskew, 'spikepercentvals', spikepercentvals, ...
  'spikebincounts', spikebincounts, 'spikebinedges', spikebinedges, ...
  'spectfreqs', spectfreqs, 'spectmedian', spectmedian, ...
  'spectiqr', spectiqr, 'spectskew', { spectskew }, ...
  'persistvals', persistvals, 'persistfreqs', persistfreqs, ...
  'persistpowers', persistpowers );


%
% Done.

end


%
% This is the end of the file.
