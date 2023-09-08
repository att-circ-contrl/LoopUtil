function newftdata = nlFT_removeArtifactsSigma( oldftdata, ...
  ampthresh, derivthresh, ampthreshfall, derivthreshfall, ...
  trimbefore_secs, trimafter_secs, smoothsecs, dcsecs )

% function newftdata = nlFT_removeArtifactsSigma( oldftdata, ...
%   ampthresh, derivthresh, ampthreshfall, derivthreshfall, ...
%   trimbefore_ms, trimafter_ms, smoothsecs, dcsecs )
%
% This identifies artifacts as excursions in signals' amplitude or
% derivative, and replaces affected regions with NaN. Excursion thresholds
% are expressed in terms of the standard deviation of the signal or its
% derivative.
%
% This is a wrapper for nlArt_removeArtifactsSigma.
%
% "oldftdata" is a Field Trip dataset to process.
% "ampthresh" is the threshold for flagging amplitude excursion artifacts.
% "derivthresh" is the threshold for flagging derivative excursion artifacts.
% "ampthreshfall" is the turn-off threshold for amplitude artifacts.
% "derivthreshfall" is the turn-off threshold for derivative artifacts.
% "trimbefore_ms" is the number of milliseconds to squash before the artifact.
% "trimafter_ms" is the number of milliseconds to squash after the artifact.
% "derivsmooth_ms" is the size in milliseconds of the smoothing window to
%   apply before taking the derivative, or 0 or NaN for no smoothing.
% "dcsecs" is the size in seconds of the window for computing local DC
%   average removal ahead of computing statistics.
%
% "newftdata" is a copy of "oldftdata" with artifacts replaced with NaN.


newftdata = oldftdata;

trialcount = length(newftdata.time);
chancount = length(ftdata.label);

if isnan(derivsmooth_ms)
  derivsmooth_ms = 0;
end

for tidx = 1:trialcount
  thistime = newftdata.time{tidx};
  thistrial = newftdata.trial{tidx};

  samprate = 1 / mean(diff(thistime));

  for cidx = 1:chancount
    thiswave = thistrial(cidx,:);

    thiswave = nlArt_removeArtifactsSigma( thiswave, ...
      ampthresh, derivthresh, ampthreshfall, derivthreshfall, ...
      round(trimbefore_ms * samprate / 1000), ...
      round(trimafter_ms * samprate / 1000), ...
      round(derivsmooth_ms * samprate / 1000), ...
      round(dcsecs * samprate) );

    thistrial(cidx,:) = thiswave;
  end

  newftdata.trial{tidx} = thistrial;
end


% Done.
end


%
% This is the end of the file.
