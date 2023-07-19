function [ peakfreqs peakheights peakwidths ] = ...
  nlFT_findSpectrumPeaks( ftdata, peakwidth, backgroundwidth, peakthresh )

% function [ peakfreqs peakheights peakwidths ] = ...
%   nlFT_findSpectrumPeaks( ftdata, peakwidth, backgroundwidth, peakthresh )
%
% This calls nlProc_findSpectrumPeaks for every trial and channel waveform
% in a Field Trip dataset. This is intended to identify tone noise.
%
% "ftdata" is a ft_datatype_raw dataset.
% "peakwidth" is the relative width of the fine-resolution frequency bins
%   used for peak detection. A value of 0.1 would mean a bin width of 2 Hz
%   at a frequency of 20 Hz.
% "backgroundwidth" is the ratio between the upper and lower frequencies of
%   the span used to evaluate the spectrum background around putative peaks.
%   A value of 2.0 would mean evaluating noise over a one-octave span.
% "peakthresh" is the magnitude threshold for recognizing a peak in the
%   frequency spectrum. This is a multiple of the average local background.
%
% "peakfreqs" is a Ntrials x Nchannels cell array containing vectors with
%   detected peak frequencies.
% "peakheights" is a Ntrials x Nchannels cell array containing vectors with
%   detected peak heights normalized to the background level.
% "peakwidths" is a Ntrials x Nchannels cell array containing vectors with
%   detected relative peak widths (FWHM / frequency).


peakfreqs = {};
peakheights = {};
peakwidths = {};

chancount = length(ftdata.label);
trialcount = length(ftdata.time);

for tidx = 1:trialcount
  thistime = ftdata.time{trialcount};
  samprate = 1 / mean(diff(thistime));

  for cidx = 1:chancount
    thiswave = ftdata.trial{tidx}(cidx,:);
    thiswave = transpose(thiswave);

    [ thisfreqlist thisheightlist thiswidthlist binlevels bencenters ] = ...
      nlProc_findSpectrumPeaks( thiswave, samprate, ...
        peakwidth, backgroundwidth, peakthresh );

    peakfreqs{tidx,cidx} = thisfreqlist;
    peakheights{tidx,cidx} = thisheightlist;
    peakwidths{tidx,cidx} = thiswidthlist;
  end
end


% Done.
end


%
% This is the end of the file.
