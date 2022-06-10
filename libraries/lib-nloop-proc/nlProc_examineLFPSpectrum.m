function [ isgood typelabel fitexponent ...
  spectpowers spectfreqs fitpowers ] = nlProc_examineLFPSpectrum( ...
    wavedata, samprate, freqrange, binwidth )

% function [ isgood typelabel fitexponent ...
%   spectpowers spectfreqs fitpowers ] = nlProc_examineLFPSpectrum( ...
%     wavedata, samprate, freqrange, binwidth )
%
% This takes the power spectrum of the specified signal, bins it in the
% log-frequency domain, rejects narrow peaks, and then tries to fit a power
% law curve to it. If this looks like pink noise or red noise, it's a valid
% LFP; if this looks like white noise or like hash, it isn't.
%
% FIXME - In a perfect world we'd evaluate "burstiness" and give different
% labels based on whether a valid LFP was quiet or bursty. That's NYI.
%
% "wavedata" is a vector containing waveform sample data.
% "samprate" is the sampling rate of the waveform data.
% "freqrange" [ min max ] is the range of frequencies to fit over.
% "binwidth" is the relative width of frequency bins. A value of 0.1 would
%   mean a bin width of 2 Hz for a bin with a center frequency of 20 Hz.
%
% "isgood" is true if the spectrum looks like LFP background, false otherwise.
% "typelabel" is a human-readable descriptive label. Typical values are
%   'lfp', 'lfpbad', 'whitenoise', 'powerlaw', and 'hash'.
% "fitexponent" is the exponent of the power-law fit. Pink noise is -1, red
%   noise is -2.
% "spectpowers" are the binned power spectrum powers (linear, not dB).
% "spectfreqs" are the spectrum bin center frequencies in Hz.
% "fitpowers" are the curve-fit power law powers at the bin frequencies.


% Initialize output.

isgood = false;
typelabel = 'unknown';
fixexponent = 0;
spectpowers = [];
spectfreqs = [];
fitpowers = [];


% FIXME - Magic values.

maxgoodexp = -1;
mingoodexp = -2.5;

maxfitratio = 2;


% Get the power spectrum (squared magnitude of the frequency spectrum).

sampcount = length(wavedata);
duration = sampcount / samprate;

wavespect = fft(wavedata);
% We could multiply by the complex conjugate, but this is more readable.
wavespect = abs(wavespect);
wavespect = wavespect .* wavespect;

freqlist = 0:(sampcount-1);
freqlist = freqlist / duration;


% Figure out our bin edges (and centers).

binedges = log(min(freqrange)):log(1+binwidth):log(max(freqrange));
binedges = exp(binedges);
bincount = length(binedges) - 1;

spectfreqs = 0.5 * ( binedges(2:(bincount+1)) + binedges(1:bincount) );


% Get the average power in each bin.

spectpowers = nan(size(spectfreqs));
for bidx = 1:bincount
  thismask = (freqlist >= binedges(bidx)) & (freqlist <= binedges(bidx+1));
  thisdata = wavespect(thismask);
  if ~isempty(thisdata)
    spectpowers(bidx) = mean(thisdata);
  end
end


% Make a copy of the power spectrum and NaN out any narrow peaks.
% NaN always compares false, so incomplete spectrum regions are tolerated.

binpowers = spectpowers;
thismask = ( binpowers(2:(bincount-1)) > binpowers(1:(bincount-2)) ) ...
  & ( binpowers(2:(bincount-1)) > binpowers(3:bincount) );
thismask = [ false thismask false ];
binpowers(thismask) = NaN;

% Get rid of NaN components. Also get rid of zeros.

thismask = isfinite(binpowers) & (binpowers > 0);
maskedpowers = binpowers(thismask);
maskedfreqs = spectfreqs(thismask);


% Do a line fit in the log domain to get a power spectrum.

maskedpowers = log(maskedpowers);
maskedfreqs = log(maskedfreqs);

lincoeffs = polyfit(maskedfreqs, maskedpowers, 1);
fitexponent = lincoeffs(1);

% Get the curve fit spectrum in all frequency bins.
fitpowers = polyval(lincoeffs, log(spectfreqs));
fitpowers = exp(fitpowers);

% Get the masked curve fit as well, to evaluate goodness-of-fit.
maskedfit = polyval(lincoeffs, maskedfreqs);


%
% Decide what the fit looks like and how good the fit is.

% We're still in the log domain. That makes life easier.
fitratio = maskedpowers - maskedfit;
fitratio = mean(abs(fitratio));
ratiogood = fitratio <= log(maxfitratio);

isgood = false;
typelabel = 'unknown';

if (fitexponent <= maxgoodexp) && (fitexponent >= mingoodexp)
  % This falls in our pink/red noise category for LFP. See if it's a good fit.

  typelabel = 'lfpbad';

  if ratiogood
    % This is a relatively clean LFP spectrum.
    % This is the only case we'll actually _flag_ as "good".
    typelabel = 'lfp';
    isgood = true;
  end
elseif ratiogood
  % Decent power law fit. See if it's white noise or something else.

  typelabel = 'powerlaw';

  if abs(fitexponent) < 0.5
    typelabel = 'whitenoise';
  end
else
  % Not a good power law fit of any kind.
  typelabel = 'hash';
end




% Done.

end


%
% This is the end of the file.
