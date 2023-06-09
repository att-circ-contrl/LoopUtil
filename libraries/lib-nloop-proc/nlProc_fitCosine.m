function [ fitmag fitfreq fitphase fitpoly ] = nlProc_fitCosine( ...
  wavedata, samprate, freqrange, polyorder )

% function [ fitmag fitfreq fitphase fitpoly ] = nlProc_fitCosine( ...
%   wavedata, samprate, freqrange, polyorder )
%
% This curve-fits a constant-amplitude cosine to the specified input wave.
% This is intended to be used when the approximate frequency is known.
%
% A polynomial-fit background is optionally subtracted before the cosine fit
% is performed. If unspecified, order 0 is used (mean subtraction).
%
% "wavedata" is the waveform data series to curve fit.
% "samprate" is the sampling rate of the waveform.
% "freqrange" [ min max ] is the frequency range to curve fit across.
% "polyorder" (optional) is the polynomial fit order to use before doing the
%   cosine fit. This defaults to 0th order (mean subtraction).
%
% "fitmag" is the amplitude of the curve-fit cosine wave.
% "fitfreq" is the frequency of the curve-fit cosine wave.
% "fitphase" is the phase of the curve-fit cosine wave at the first sample
%   of the input wave.
% "fitpoly" is a row vector containing polynomial fit coefficients, highest
%   order first. For 0th order (default), this is a scalar containing the
%   mean of the input signal.


fitmag = NaN;
fitfreq = NaN;
fitphase = NaN;
fitpoly = NaN;


% Default to 0th order.
if ~exist('polyorder', 'var')
  polyorder = 0;
end



% Get initial useful information.

sampcount = length(wavedata);

timeseries = 1:sampcount;
timeseries = (timeseries - 1) / samprate;


% Do the polynomial fit.

fitpoly = polyfit(timeseries, wavedata, polyorder);

bgwave = polyval(fitpoly, timeseries);
bgwave = reshape(bgwave, size(wavedata));



% FIXME - Doing this using a brute force frequency sweep.


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

need_optimize_bg = false;

for thisfreq = min(freqrange):freqstep:max(freqrange)

  thisomega = 2 * pi * thisfreq;
  cosseries = cos(timeseries * thisomega);
  sinseries = sin(timeseries * thisomega);

  if false
    % Express the input as a * cos(t) + b * sin(t).
    % De-trend/de-mean as a separate step.

    % Subtract the polynomial fit.
    zerowave = wavedata - bgwave;

    % FIXME - This only works for an integer number of periods!
    afactor = (2 / sampcount) * sum( zerowave .* cosseries );
    bfactor = (2 / sampcount) * sum( zerowave .* sinseries );
  end

  if true
    % Express the input as a * cos(t) + b * sin(t).
    % De-trend/de-mean as a separate step.

    % Subtract the mean.
    % Subtract the polynomial fit.
    zerowave = wavedata - bgwave;

    % General case for a fractional number of periods.
    % FIXME - We're neglecting terms related to the mean, which can perturb
    % the result.
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
    % FIXME - This overrides the choice of polynomial order.

    % General case for a fractional number of periods, including mu.
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

    % FIXME - Override the polynomial fit.
    need_optimize_bg = true;
    thispoly = abvector(3);
  end


  % Calculate the squared error after the fit and save this if it's an
  % improvement.

  thisrecon = afactor * cosseries + bfactor * sinseries + bgwave;
  thiserr = wavedata - thisrecon;
  thiserr = sum(thiserr .* thiserr);

  if thiserr < besterr
    besterr = thiserr;

    % A positive sine component gives a negative phase offset, and vice versa.
    thiscoeff = afactor - i * bfactor;

    fitmag = abs(thiscoeff);
    fitphase = angle(thiscoeff);
    fitfreq = thisfreq;

    if need_optimize_bg
      fitpoly = thispoly;
    end
  end

end


% Done.
end


%
% This is the end of the file.
