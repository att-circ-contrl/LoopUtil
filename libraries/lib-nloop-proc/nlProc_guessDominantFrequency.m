function [ estfreq estmag ] = nlProc_guessDomiantFrequency( ...
  wavedata, samprate, freqrange )

% function [ estfreq estmag ] = nlProc_guessDomiantFrequency( ...
%   wavedata, samprate, freqrange )
%
% This function identifies the highest-magnitude frequency component in the
% supplied waveform and extracts its frequency and magnitude.
%
% "wavedata" is the waveform to analyze.
% "samprate" is the sampling rate.
% "freqrange" [ min max ] is the range of frequencies to consider.
%
% "estfreq" is the estimated frequency of the largest component.
% "estmag" is the magnitude of that frequency component.


%
% Do this the straightforward way (Fourier transform).


sampcount = length(wavedata);


% Get the spectrum.

thisspect = fft(wavedata);


% Get the associated frequencies.

spectfreqs = 0:(sampcount-1);
spectfreqs = (spectfreqs / sampcount) * samprate;


% Mask to the desired frequency range.
% Blithely assume that the supplied frequency range is less than the
% Nyquist frequency.

freqmask = (spectfreqs >= min(freqrange)) & (spectfreqs <= max(freqrange));
thisspect = thisspect(freqmask);
spectfreqs = spectfreqs(freqmask);


% Figure out what our largest component is and select it.

thisspect = abs(thisspect);
estmag = max(thisspect);
bestidx = min(find( thisspect >= (estmag * 0.999) ));
estfreq = spectfreqs(bestidx);

% Matlab's convetion has the IFFT do the division, rather than using sqrt(n)
% for FFT and IFFT.
estmag = estmag / sampcount;


% Done.
end


%
% This is the end of the file.
