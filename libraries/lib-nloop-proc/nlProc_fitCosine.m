function [ fitmag fitfreq fitphase ] = nlProc_fitCosine( ...
  wavedata, samprate, freqrange )

% function [ fitmag fitfreq fitphase ] = nlProc_fitCosine( ...
%   wavedata, samprate, freqrange )
%
% This curve-fits a constant-amplitude cosine to the specified input wave.
%
% This is intended to be used when the approximate frequency is known.
%
% "wavedata" is the waveform series to curve fit.
% "samprate" is the sampling rate of the waveform.
% "freqrange" [ min max ] is the frequency range to curve fit across.
%
% "fitmag" is the amplitude of the curve-fit cosine wave.
% "fitfreq" is the frequency of the curve-fit cosine wave.
% "fitphase" is the phase of the curve-fit cosine wave at the first sample
%   of the input wave.


fitmag = NaN;
fitfreq = NaN;
fitphase = NaN;


% FIXME - Doing this by brute force.


sampcount = length(wavedata);

timeseries = 1:sampcount;
timeseries = (timeseries - 1) / samprate;


% Get a reasonable range of frequencies to test.
% The Fourier transform would have a step size equal to the fundamental mode.

fundfreq = samprate / sampcount;
freqdelta = max(freqrange) - min(freqrange);

% Test at least 10 and at most 100 frequencies, for sanity.
freqstep = min(0.1 * freqdelta, fundfreq);
freqstep = max(0.01 * freqdelta, freqstep);


for thisfreq = min(freqrange):freqstep:max(freqrange)

  % Express the input as a * cos(t) + b * sin(t).

  thisomega = 2 * pi * thisfreq;
  cosseries = cos(timeseries * thisomega);
  sinseries = sin(timeseries * thisomega);

  afactor = (2 / sampcount) * sum( wavedata .* cosseries );
  bfactor = (2 / sampcount) * sum( wavedata .* sinseries );

  thiscoeff = afactor + i * bfactor;
  thismag = abs(thiscoeff);
  if isnan(fitmag) || (thismag > fitmag)
    fitmag = thismag;
    fitphase = angle(thiscoeff);
    fitfreq = thisfreq;
  end

end


% Done.
end


%
% This is the end of the file.
