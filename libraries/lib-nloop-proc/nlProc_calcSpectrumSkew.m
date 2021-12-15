function [ spectfreqs spectmedian spectiqr spectskew ] = ...
  nlProc_calcSpectrumSkew( dataseries, samprate, ...
  freqrange, freqperdecade, wintime, winsteps, tailpercent)

% function [ spectfreqs spectmedian spectiqr spectskew ] = ...
%   nlProc_calcSpectrumSkew( dataseries, samprate, ...
%   freqrange, freqperdecade, wintime, winsteps, tailpercent)
%
% This computes a persistence spectrum for the specified series, and finds
% the median, interquartile range, and the normalized skew for each frequency
% bin. "Skew" is defined per nlProc_calcSkewPercentile().
%
% "dataseries" is the data series to process.
% "samprate" is the sampling rate of the data series.
% "freqrange" [ fmin fmax ] specifies the frequency band to evaluate.
% "freqperdecade" is the number of frequency bins per decade.
% "wintime" is the window duration in seconds to compute the time-windowed
%   Fourier transform with.
% "winsteps" is the number of overlapping steps taken when advancing the time
%   window. The window advances by wintime/winsteps seconds per step.
% "tailpercent" is an array of percentile values that define the tails for
%   skew calculation, per nlProc_calcSkewPercentile().
%
% "spectfreqs" is an array of bin center frequencies.
% "spectmedian" is an array of per-frequency median power values.
% "spectiqr" is an array of per-frequency power interquartile ranges.
% "spectskew" is a cell array, with one cell per "tailpercent" value. Each
%   cell contains an array of per-frequency skew values.


  sampcount = length(dataseries);

  winsamps = round(wintime * samprate);
  stepsamps = round(winsamps / winsteps);

  % Build a list of frequency bin intervals in the fft output.
  fmin = log(min(freqrange));
  fmax = log(max(freqrange));
  fstep = log(10) / freqperdecade;
  freqvals = fmin:fstep:fmax;
  freqvals = exp(freqvals);
  % Successive harmonics differ by (1/wintime) Hz.
  % The 0th harmonic (DC) is at sample 1.
  % (freq / step) + 1 is (freq * winsize) + 1.
  freqlut = freqvals * wintime;
  freqlut = round(1 + freqlut);


  % First pass: Get the persistence spectrum.

  powerseries = {};

  for fidx = 2:length(freqlut)
    powerseries{fidx-1} = [];
  end

  for sidx = 1:stepsamps:sampcount
    if (sidx + winsamps - 1) <= sampcount

      thisdata = dataseries( sidx : (sidx + winsamps - 1) );

      thisspect = fft(thisdata);
      for fidx = 2:length(freqlut)
        thispseries = powerseries{fidx-1};

        thispower = thisspect(freqlut(fidx-1):freqlut(fidx));
        thispower = abs(thispower);
        thispower = thispower .* thispower;
        % Mean rather than sum to get the density, not absolute power.
        thispseries(1 + length(thispseries)) = mean(thispower);

        powerseries{fidx-1} = thispseries;
      end

    end
  end


  % Second pass: Get statistics for the persistence spectrum.

  spectfreqs = [];
  spectmedian = [];
  spectiqr = [];
  spectskew = {};

  for fidx = 1:(length(freqlut) - 1)

    % Assume bins cover a small enough range that we don't need the geometric
    % mean.
    spectfreqs(fidx) = 0.5 * (freqvals(fidx) + freqvals(fidx+1));

    thispseries = powerseries{fidx};
    [ thismedian thisiqr thisskew thispercentlist ] = ...
      nlProc_calcSkewPercentile(thispseries, tailpercent);

    spectmedian(fidx) = thismedian;
    spectiqr(fidx) = thisiqr;

    for pidx = 1:length(tailpercent)
      spectskew{pidx}(fidx) = thisskew(pidx);
    end

  end


%
% Done.

end


%
% This is the end of the file.
