function query_vals = ...
  nlProc_sampleWaveAtTimes( signal_times, signal_vals, query_times )

% function query_vals = ...
%   nlProc_sampleWaveAtTimes( signal_times, signal_vals, query_times )
%
% This function measures the value of a signal waveform at a list of
% specified times.
%
% The signal is assumed to be uniformly sampled ("signal_times" is a linear
% sequence). The signal must contain at least two samples.
%
% "signal_times" is a vector containing waveform timestamps. This should be
%   a linear sequence (uniform sampling).
% "signal_vals" is a vector containing waveform values at each timestamp.
% "query_times" is a vector containing times at which to measure the
%   signal waveform. There are no constraints on these values.
%
% "query_vals" is a vector containing waveform values at the times listed
%   in "query_times". Out-of-range timestamps get NaN values.


% Initialize to NaN.
query_vals = NaN(size(query_times));


% Get the extents and the sampling rate.

sampcount = length(signal_times);
firsttime = signal_times(1);
lasttime = signal_times(sampcount);
samprate = (sampcount - 1) / (lasttime - firsttime);


% Convert query times to query sample indices, and store copied values.

query_times = round( (query_times - firsttime) * samprate ) + 1;
validmask = (query_times >= 1) & (query_times <= sampcount);

query_indices = query_times(validmask);

query_vals(validmask) = signal_vals(query_indices);


% Done.
end


%
% This is the end of the file.
