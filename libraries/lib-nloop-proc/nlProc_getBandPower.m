function [ spectpower tonepower ] = ...
  nlProc_getBandPower( chandata, samprate, freqedges )

% function [ spectpower tonepower ] = ...
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


spectpower = [];
tonepower = [];


if iscell(chandata)

  % Multiple trials. Recurse trial by trial.

  ntrials = length(chandata);

  for tidx = 1:ntrials
    [ thisspect thistone ] = ...
      nlProc_getBandPower( chandata{tidx}, samprate, freqedges );

    if isempty(spectpower)
      spectpower = thisspect;
      tonepower = thistone;
    else
      spectpower(:,:,tidx) = thisspect;
      tonepower(:,:,tidx) = thistone;
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

end


% Done.
end

%
% This is the end of the file.
