function [ peakfreqs peakheights peakwidths binlevels bincenters ] = ...
  nlProc_findSpectrumPeaks( ...
    wavedata, samprate, peakwidth, backgroundwidth, peakthresh )

% function [ peakfreqs peakheights peakwidths binlevels bincenters ] = ...
%   nlProc_findSpectrumPeaks( ...
%     wavedata, samprate, peakwidth, backgroundwidth, peakthresh )
%
% This takes the frequency spectrum of the specified signal, bins it in the
% log-frequency domain, and looks for narrow peaks against the background.
%
% "wavedata" is a vector containing waveform sample data.
% "samprate" is the sampling rate of the waveform data.
% "peakwidth" is the relative width of the fine-resolution frequency bins.
%   A value of 0.1 would mean a bin width of 2 Hz at a frequency of 20 Hz.
% "backgroundwidth" is the ratio between the upper and lower frequencies of
%   the span used to evaluate noise background around any given bin. A value
%   of 2.0 would mean evaluating noise over a one-octave span.
% "peakthresh" is the magnitude threshold for recognizing a peak in the
%   frequency spectrum. This is a multiple of the average local background.
%
% "peakfreqs" is a vector containing peak center frequencies in Hz.
% "peakheights" is a vector containing peak heights relative to the background.
% "peakwidths" is a vector containing relative peak widths (FWHM / frequency).
% "binmags" is a vector containing frequency spectrum bin magnitudes.
% "binfreqs" is a vector containing frequency spectrum bin center frequencies.


% Initialize output.

peakfreqs = [];
peakheights = [];
peakwidths = [];

peakcount = 0;


% FIXME - Magic numbers for the frequency range of interest.
minfreq = 4.0;
maxfreq = 4000.0;

maxfreq = min(maxfreq, 0.3*samprate);


% Get the frequency spectrum.
% We actually just want the magnitude, not the complex component values.

sampcount = length(wavedata);
duration = sampcount / samprate;

wavespect = fft(wavedata);
wavespect = abs(wavespect);

freqlist = 0:(sampcount-1);
freqlist = freqlist / duration;


% Figure out what our frequency bins look like.

binedges = log(minfreq):log(1 + peakwidth):log(maxfreq);
binedges = exp(binedges);
bincount = length(binedges) - 1;

% This is the background radius around each narrow bin.
backradius = log(backgroundwidth) / log(1 + peakwidth);
backradius = round(backradius / 2);
backradius = max(1, backradius);

% FIXME - Kludge the FWHM search radius.
% The idea is to properly detect peaks that are wider than we expected.
searchradius = round(sqrt(backradius));
searchradius = max(1, searchradius);


% Get the average magnitude in each bin.

binlevels = [];
for bidx = 1:bincount
  thismask = (freqlist >= binedges(bidx)) & (freqlist <= binedges(bidx+1));
  thisspect = wavespect(thismask);
  binlevels(bidx) = mean(thisspect);
end

% Get the bin centers, for plotting.
bincenters = 0.5 * ( binedges(2:(bincount+1)) + binedges(1:bincount) );


% Get the average background in each bin.
% NOTE - Do this by averaging bins, not the spectrum.
% Otherwise we'd be giving undue weight to higher frequencies, which have
% more samples per bin.

binbackground = nan(size(binlevels));
for bidx = (1 + backradius):(bincount - backradius)
  thisbinlist = binlevels( (bidx - backradius):(bidx + backradius) );
  binbackground(bidx) = mean(thisbinlist);
end


% Identify bins above background.
% For each of these bins, get center frequency and FWHM of the peak.

binmask = (binlevels >= (peakthresh * binbackground));

for bidx = find(binmask)

  % NOTE - We're getting false positives from broad peaks.
  % Only consider bins that are local maxima.

  if (binlevels(bidx) > binlevels(bidx-1)) ...
    && (binlevels(bidx) > binlevels(bidx+1))

    % Look for the peak and flanks within nearby bins.
    % FIXME - This will get confused by clusters of peaks.

    thismask = (freqlist >= binedges(bidx-searchradius)) ...
      & (freqlist <= binedges(bidx+searchradius));
    thisspect = wavespect(thismask);
    thisfreq = freqlist(thismask);


    thismax = max(thisspect);
    thisfloor = binbackground(bidx);

    fidx = find(thisspect >= 0.5 * thismax);

    % Call the peak location the center of the FWHM region.
    thisfreqcenter = thisfreq(round(mean(fidx)));

    thisfreqmax = thisfreq(max(fidx));
    thisfreqmin = thisfreq(min(fidx));
    thisfwhm = thisfreqmax - thisfreqmin;


    % Add this peak's metadata to the output list.

    peakcount = peakcount + 1;
    peakfreqs(peakcount) = thisfreqcenter;
    peakheights(peakcount) = thismax / thisfloor;
    peakwidths(peakcount) = thisfwhm / thisfreqcenter;
  end
end


% Done.

end


%
% This is the end of the file.
