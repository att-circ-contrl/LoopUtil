function [ spectpower tonepower normspect normtone ] = ...
  nlProc_getBandPower( chandata, samprate, freqedges )

% function [ spectpower tonepower normspect normtone ] = ...
%   nlProc_getBandPower( chandata, samprate, freqedges )
%
% This processes a matrix of multi-channel waveforms, evaluating spectral
% power within each band and the height of any peaks within each band.
%
% "chandata" is a nChans x nSamples matrix containing waveform data.
%   Alternatively it may be a cell array of such matrices (multiple trials).
% "samprate" is the sampling rate of the data.
% "freqedges" is a vector of length (nBands + 1) containing bin edges for
%   binning frequency.
%
% "spectpower" is a nChans x nBands x nTrials matrix containing in-band
%   total power for each channel and band (and trial, if multiple trials
%   were present). Note that Matlab drops trailing dimensions of length 1.
% "tonepower" is a nChans x nBands x nTrials matrix containing the ratio
%   of the maximum power to median power of the components within each
%   band. This is the normalized intensity of any narrow-band spikes.
% "normspect" is a copy of "spectpower" with each (:,bidx,tidx) slice
%   normalized so that 0 is the median power across channels and +/- 1 is
%   approximately one standard deviation from the median (1.5 quartiles).
% "normtone" is a copy of "tonepower" with each (:,bidx,tidx) slice
%   converted to log scale and normalized in the same manner as "normspect".


spectpower = [];
tonepower = [];
normspect = [];
normtone = [];


if iscell(chandata)

  % Multiple trials. Recurse trial by trial.

  ntrials = length(chandata);

  for tidx = 1:ntrials
    [ thisspect thistone thisnormspect thisnormtone ] = ...
      nlProc_getBandPower( chandata{tidx}, samprate, freqedges );

    if isempty(spectpower)
      spectpower = thisspect;
      tonepower = thistone;
      normspect = thisnormspect;
      normtone = thisnormtone;
    else
      spectpower(:,:,tidx) = thisspect;
      tonepower(:,:,tidx) = thistone;
      normspect(:,:,tidx) = thisnormspect;
      normtone(:,:,tidx) = thisnormtone;
    end
  end

else

  % One trial. Compute band power and tone power.

  freqedges = sort(freqedges);
  bandcount = length(freqedges) - 1;

  chancount = size(chandata,1);
  sampcount = size(chandata,2);


  duration = sampcount / samprate;

  % For a real-valued input signal, F(-w) is conj(F(w)), so the power
  % spectrum is symmetrical. We can ignore the above-Nyquist half.
  freqlist = 0:(sampcount-1);
  freqlist = freqlist / duration;


  for cidx = 1:chancount
    thiswave = chandata(cidx,:);

    % Power is the squared magnitude of the Fourier transform.
    wavespect = fft(thiswave);
    wavespect = abs(wavespect);
    wavespect = wavespect .* wavespect;

    for bidx = 1:bandcount
      minfreq = freqedges(bidx);
      maxfreq = freqedges(bidx+1);
      binmask = (freqlist >= minfreq) & (freqlist <= maxfreq);

      thispower = NaN;
      thistone = NaN;

      if any(binmask)
        thisdata = wavespect(binmask);
        thispower = sum(thisdata);
        thistone = max(thisdata) / median(thisdata);
      end

      spectpower(cidx,bidx) = thispower;
      tonepower(cidx,bidx) = thistone;
    end
  end


  % Perform across-channel normalization.

  normspect = nan(size(spectpower));
  normtone = nan(size(tonepower));

  for bidx = 1:bandcount
    % Normalize in-band power so that the median is 0.
    % Scale above and below median independently, so that quartiles are
    % +/- 0.67 (making 1 standard deviation approximately +/- 1).

    thisspect = spectpower(:,bidx);
    thisspect = thisspect - median(thisspect);

    posmask = (thisspect >= 0);
    negmask = ~posmask;

    % These are scale factors, so we want both of them to be positive.
    posamp = prctile(thisspect, 75);
    negamp = abs( prctile(thisspect, 25) );

    thisspect(posmask) = 0.67 * thisspect(posmask) / posamp;
    thisspect(negmask) = 0.67 * thisspect(negmask) / negamp;

    normspect(:,bidx) = thisspect;


    % Convert tone power to log scale and normalize it so that the median
    % is 0. Scale above and below median using a common scale factor (from
    % the IQR), again scaled so that 1 sigma is approximately +/- 1.

    % We know that the tone power is 1 or higher, so taking log always works.
    thistone = tonepower(:,bidx);
    thistone = log(thistone);
    thistone = thistone - median(thistone);

    tonequarts = prctile(thistone, [ 25 75 ]);
    toneiqr = max(tonequarts) - min(tonequarts);

    % Half our IQR is our nominal median-to-quartile distance.
    thistone = 0.67 * thistone / (0.5 * toneiqr);

    normtone(:,bidx) = thistone;
  end

end


% Done.
end

%
% This is the end of the file.
