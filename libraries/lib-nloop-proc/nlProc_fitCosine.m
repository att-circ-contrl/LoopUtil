function [ fitmag fitfreq fitphase fitmean ] = nlProc_fitCosine( ...
  wavedata, samprate, freqrange )

% function [ fitmag fitfreq fitphase fitmean ] = nlProc_fitCosine( ...
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
% "fitmean" is the mean of the input (subtracted before the curve fit).


fitmag = NaN;
fitfreq = NaN;
fitphase = NaN;
fitmean = NaN;


% FIXME - Doing this by brute force.


sampcount = length(wavedata);

timeseries = 1:sampcount;
timeseries = (timeseries - 1) / samprate;


% Get a reasonable range of frequencies to test.

% The Fourier transform would have a step size equal to the fundamental mode.
% Start with that but clamp it to between 0.003 and 0.03 times the frequency
% range (test at least 30 and at most 300 frequencies).

fundfreq = samprate / sampcount;

freqdelta = max(freqrange) - min(freqrange);

% No larger than 1/30 of the range.
freqstep = min(0.03 * freqdelta, fundfreq);
% No smaller than 1/300 of the range.
freqstep = max(0.003 * freqdelta, freqstep);


besterr = inf;

for thisfreq = min(freqrange):freqstep:max(freqrange)

  thisomega = 2 * pi * thisfreq;
  cosseries = cos(timeseries * thisomega);
  sinseries = sin(timeseries * thisomega);

  if false
    % Express the input as a * cos(t) + b * sin(t).
    % Get the mean as a separate step.

    % Subtract the mean.
    fitmean = mean(wavedata);
    zerowave = wavedata - fitmean;

    % FIXME - This only works for an integer number of periods!
    afactor = (2 / sampcount) * sum( zerowave .* cosseries );
    bfactor = (2 / sampcount) * sum( zerowave .* sinseries );
  end

  if true
    % Express the input as a * cos(t) + b * sin(t).
    % Get the mean as a separate step.

    % Subtract the mean.
    fitmean = mean(wavedata);
    zerowave = wavedata - fitmean;

    % General case for a fractional number of periods.
    % FIXME - Computing the mean ahead of time causes this to be perturbed!
    % [a ; b] = inv([ sum(cos2), sum(sincos) ; sum(sincos), sum(cos2) ]) times
    %   [ sum(x(t)cos) ; sum(x(t)sin) ]

    xvector = [ sum(zerowave .* cosseries) ; sum(zerowave .* sinseries) ];

    sumcos2 = sum(cosseries .* cosseries);
    sumsin2 = sum(sinseries .* sinseries);
    sumsincos = sum(sinseries .* cosseries);

    scmatrix = [ sumcos2 sumsincos ; sumsincos sumsin2 ];
    abvector = inv(scmatrix) * xvector;

    afactor = abvector(1);
    bfactor = abvector(2);
  end

  if false
    % Express the input as a * cos(t) + b * sin(t) + mu.

    % General case for a fractional number of periods, including mu.
    % FIXME - This will sometimes perturb mu strangely (stability issues?).
    % [a ; b; mu] = inv( ...
    %   [ sum(cos2), sum(sincos), sum(cos) ; ...
    %     sum(sincos), sum(cos2), sum(sin) ; ...
    %     sum(cos), sum(sin), sum(1) ]) ...
    %   * [ sum(x(t)cos) ; sum(x(t)sin) ; sum(x(t)) ]

    xvector = [ sum(wavedata .* cosseries) ; sum(wavedata .* sinseries) ; ...
      sum(wavedata) ];

    sumcos2 = sum(cosseries .* cosseries);
    sumsin2 = sum(sinseries .* sinseries);
    sumsincos = sum(sinseries .* cosseries);
    sumcos = sum(cosseries);
    sumsin = sum(sinseries);
    sumone = length(timeseries);

    scmatrix = [ sumcos2 sumsincos sumcos; sumsincos sumsin2 sumsin ; ...
      sumcos sumsin sumone ];

    abvector = inv(scmatrix) * xvector;

    afactor = abvector(1);
    bfactor = abvector(2);
    fitmean = abvector(3);
  end


  % Calculate the squared error after the fit and save this if it's an
  % improvement.

  thisrecon = afactor * cosseries + bfactor * sinseries + fitmean;
  thiserr = wavedata - thisrecon;
  thiserr = sum(thiserr .* thiserr);

  if thiserr < besterr
    besterr = thiserr;

    % A positive sine component gives a negative phase offset, and vice versa.
    thiscoeff = afactor - i * bfactor;

    fitmag = abs(thiscoeff);
    fitphase = angle(thiscoeff);
    fitfreq = thisfreq;
  end

end


% Done.
end


%
% This is the end of the file.
