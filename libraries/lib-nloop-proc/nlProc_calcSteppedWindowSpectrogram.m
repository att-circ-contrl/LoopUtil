function [ freqlist timelist spectpowers ] = ...
  nlProc_calcSteppedWindowSpectrogram( ...
    timeseries, waveseries, winsize, winstep, timespan, freqspan )

% function [ freqlist timelist spectpowers ] = ...
%   nlProc_calcSteppedWindowSpectrogram( ...
%     timeseries, waveseries, winsize, winstep, timespan, freqspan )
%
% This computes a spectrogram of a signal using a stepped rectangular
% window.
%
% The waveform is assumed to include the requested time span.
%
% "timeseries" is a vector containing sample timestamps.
% "waveseries" is a vector containing waveform values.
% "winsize" is the window duration in seconds.
% "winstep" is the window step distance in seconds.
% "timespan" [ min max ] is the time region within which the window is to
%   be stepped.
% "freqspan" [ min max ] is the range of frequencies to evaluate.
%
% "freqlist" is a vector containing frequencies for which power was computed.
% "timelist" is a vector containing window center times that were evaluated.
% "spectpowers" is a nTimes x nFrequencies matrix containing evaluated
%   spectral power (in arbitrary units).


% Initialize.
freqlist = [];
timelist = [];
spectpowers = [];


% NOTE - We may get called repeatedly from nlFT_calcSteppedWindowSpectrogram.
% Try to make sure that we produce consistent time and frequency lists.

% Consistent time lists are straightforward - calculate target times from
% "timespan", which is consistent between calls.

% Consistent frequency lists require consistent sampling rates and consistent
% window sizes. To do that, calculate the sampling rate in Hz and round it;
% this should be consistent in most use cases. Then calculate the window
% duration in samples and apply that directly, rather than applying
% conditions on the time series itself (which can give a varying length due
% to rounding errors).


% Get the sampling rate and the window radius (in samples).

samprate = mean(diff(timeseries));
samprate = round(1 / samprate);

winradsamps = round(0.5 * winsize * samprate);


% Get the number of steps and the desired window midpoint times.

% Give a little bit of wiggle room for stepping the window, to account for
% rounding if we're asked for a window that exactly fits.

timelength = max(timespan) - min(timespan);
slidelength = timelength - 0.999 * winsize;
stepcount = floor(slidelength / winstep);
stepstart = 0.5 * (timelength - stepcount * winstep);

midtimes = 0:stepcount;
midtimes = midtimes * winstep + stepstart;


% Convert the desired midpoint times to sample indices.

midsamps = [];
for midx = 1:length(midtimes)
  midsamps(midx) = min(find( timeseries >= midtimes(midx) ));
end


% Save the midpoint timestamps.

timelist = timeseries(midsamps);


% Calculate the frequency series and frequency mask, given the window size.

winsamps = 1 + winradsamps + winradsamps;
fstep = samprate / winsamps;

rawfreqs = 1:winsamps;
rawfreqs = (rawfreqs - 1) * fstep;

freqmask = (rawfreqs >= min(freqspan)) & (rawfreqs <= max(freqspan));
freqlist = rawfreqs(freqmask);

freqcount = length(freqlist);


% Step through the windows, computing and saving power spectra.

for midx = 1:length(midsamps)
  winstart = midsamps(midx) - winradsamps;
  winend = midsamps(midx) + winradsamps;

  thisfragment = waveseries(winstart:winend);

  thisspect = fft(thisfragment);
  % Power is the squared magnitude. Units are arbitrary.
  thisspect = thisspect .* conj(thisspect);

  spectfragment = thisspect(freqmask);
  % This should already be real, but roundoff errors can happen.
  spectfragment = real(spectfragment);

  spectpowers(midx,1:freqcount) = spectfragment;
end


% Done.
end


%
% This is the end of the file.
