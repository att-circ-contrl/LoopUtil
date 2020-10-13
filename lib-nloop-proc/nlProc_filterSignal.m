function [ lfpseries spikeseries ] = nlProc_filterSignal( oldseries, ...
  samprate, lfprate, lowpassfreq, powerfreq, dcfreq )

% function [ lfpseries spikeseries ] = nlProc_filterSignal( oldseries, ...
%   samprate, lfprate, lowpassfreq, powerfreq, dcfreq )
%
% This applies several filters:
% - A DC removal filter.
% - A notch filter to remove power line noise.
% - A low-pass filter to isolate the local field potential signal.
% The full-rate LFP series is subtracted from the original series to produce
% a high-pass-filtered "spike" series, and a downsampled LFP series is
% also returned.
%
% "oldseries" is the original wideband signal.
% "samprate" is the sampling rate of the wideband signal.
% "lfprate" is the desired sampling rate of the LFP signal. This should
%   cleanly divide "samprate" (samprate = k * lfprate for some integer k).
% "lowpassfreq" is the edge of the pass-band for the LFP signal. This is
%   lower than the filter's corner frequency; it's the 0.2 dB frequency.
% "powerfreq" is an array of values specifying the center frequencies of the
%   power line notch filter. This is typically 60 Hz or 50 Hz (a single
%   value), but may contain multiple values to filter harmonics. An empty
%   array disables this filter.
% "dcfreq" is the edge of the pass-band for the high-pass DC removal filter.
%   Set to 0 to disable this filter. This is higher than the corner frequency;
%   it's the 0.2 dB frequency (ripple is flat above it).
%
% "lfpseries" is the downsampled low-pass-filtered signal.
% "spikeseries" is the full-rate high-pass-filtered signal.
%
% Filters used are IIR, called with "filtfilt" to remove time offset by
% running the filter forwards and backwards in time. The power line filter
% takes about 1/2 second to fully stabilize, and the low-pass LFP filter takes
% about 1/2 period to 1 period to fully stabilize. Edge effects may occur
% within this distance of the start and end of the signal.
% The DC rejection filter also takes at least 1 period to stabilize. Since
% it's applied in both directions, and won't perturb the pass-band, it should
% be well-behaved over the entire signal.
%
% The LFP sampling rate should be at least 10 times "lowpassfreq" to avoid
% aliasing during downsampling. The DC rejection filter pass frequency
% should be no lower than half the lowest frequency of interest, to
% minimize edge effects.


% DC rejection filter.
% This is second-order, so edge effects should last about 1/3 of a period,
% but the corner frequency is lower than the pass-band frequency, so this
% will still be a substantial amount of time.
% This shouldn't perturb anything in the pass-band, so as long as the
% signal duration itself is longer than the settling time, it should be ok.
% This gets applied twice (forward and backward).

if (0.01 < dcfreq)

  dcfilt = designfilt( 'highpassiir', 'SampleRate', samprate, ...
    'PassBandFrequency', dcfreq, 'PassBandRipple', 0.2, ...
    'FilterOrder', 2 );

  oldseries = filtfilt(dcfilt, oldseries);

end


% Power line rejection filter.
% This has an order of 20 and FWHM of (freq/10). Edge effects should last for
% about 20 cycles (1/3 sec or so at 60 Hz).
% This gets applied twice (forward and backward).

for fidx = 1:length(powerfreq)

  thisfreq = powerfreq(fidx);
  notchlow = 0.95 * thisfreq;
  notchhigh = 1.05 * thisfreq;

  powerfilt = designfilt( 'bandstopiir', 'SampleRate', samprate, ...
    'HalfPowerFrequency1', notchlow, ...
    'HalfPowerFrequency2', notchhigh, ...
    'FilterOrder', 20 );

  oldseries = filtfilt(powerfilt, oldseries);

end


% LFP filter. This doubles as an anti-aliasing filter for the downsampled
% signal.
% This is third-order, so edge effects should last about 1/2 of a period.
% This gets applied twice (forward and backward).

lowpassfilt = designfilt( 'lowpassiir', 'SampleRate', samprate, ...
  'PassBandFrequency', lowpassfreq, 'PassBandRipple', 0.2, ...
  'FilterOrder', 3 );

lowpassfull = filtfilt(lowpassfilt, oldseries);


% Compute and sanity-check the decimation factor.

decimfactor = round(samprate / lfprate);
if 0 ~= mod(samprate, lfprate)
  disp(sprintf( '### [nlProc_filterSignal]  %d does not divide %d.', ...
    lfprate, samprate ));
end


% Get the LFP and spike waveforms.

spikeseries = oldseries - lowpassfull;
lfpseries = downsample(lowpassfull, decimfactor);


%
% Done.

end


%
% This is the end of the file.
