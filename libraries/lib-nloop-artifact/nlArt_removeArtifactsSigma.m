function newseries = nlArt_removeArtifactsSigma( oldseries, ...
  ampthresh, derivthresh, ampthreshfall, derivthreshfall, ...
  trimbefore, trimafter, smoothsamps, dcsamps )

% function newseries = nlArt_removeArtifactsSigma( oldseries, ...
%   ampthresh, derivthresh, ampthreshfall, derivthreshfall, ...
%   trimbefore, trimafter, smoothsamps, dcsamps )
%
% This identifies artifacts as excursions in the signal's amplitude or
% derivative, and replaces affected regions with NaN. Excursion thresholds
% are expressed in terms of the standard deviation of the signal or its
% derivative.
%
% "oldseries" is the series to process.
% "ampthresh" is the threshold for flagging amplitude excursion artifacts.
% "derivthresh" is the threshold for flagging derivative excursion artifacts.
% "ampthreshfall" is the turn-off threshold for amplitude artifacts.
% "derivthreshfall" is the turn-off threshold for derivative artifacts.
% "trimbefore" is the number of samples to squash ahead of the artifact.
% "trimafter" is the number of samples to squash after the artifact.
% "smoothsamps" is the size of the smoothing window to apply before taking
%   the derivative, or 0 for no smoothing.
% "dcsamps" is the size of the window for computing local DC average removal
%   ahead of computing signal statistics.
%
% "newseries" is a copy of "oldseries" with artifacts replaced with NaN.
%
% Regions where the amplitude or derivative exceeds the threshold are flagged
% as artifacts. These regions are widened to encompass the region where the
% amplitude or derivative exceeds the "fall" threshold, and then padded by
% the specified number of samples. This is intended to correctly handle
% square-pulse artifacts and fast-step-slow-decay artifacts.


%
% Get the derivative (or a proxy for it).

% FIXME - Apply a moving window average repeatedly, to get something closer
% to a Gaussian.

diffseries = oldseries;

if (smoothsamps >= 4)

  smoothsamps = round(0.5 * smoothsamps);

  diffseries = movmean(diffseries, smoothsamps);
  diffseries = movmean(diffseries, smoothsamps);
  diffseries = movmean(diffseries, smoothsamps);

elseif (smoothsamps >= 2)

  diffseries = movmean(diffseries, smoothsamps);

end

diffseries = diff(diffseries);

% Pad this back to the original length.
diffseries(1 + length(diffseries)) = diffseries(length(diffseries));


%
% Perform DC removal on the series and its derivative.

ampseries = oldseries;
ampseries = ampseries - movmean(ampseries, dcsamps);

diffseries = diffseries - movmean(diffseries, dcsamps);


%
% Calculate statistics and identify excursion regions.

% Force sanity.
ampthreshfall = min(ampthreshfall, ampthresh);
derivthreshfall = min(derivthreshfall, derivthresh);

ampsigma = std(ampseries);
diffsigma = std(diffseries);

ampdetect = abs(ampseries) >= ampthresh * ampsigma;
amphalo = abs(ampseries) >= ampthreshfall * ampsigma;

diffdetect = abs(diffseries) >= derivthresh * diffsigma;
diffhalo = abs(diffseries) >= derivthreshfall * diffsigma;


%
% Expand detection regions to include the halo regions and time padding.

% FIXME - There's probably a Matlab function that does this compactly, but
% I don't know offhand what that function is.

ampmask = ones(size(ampdetect));
diffmask = ones(size(diffdetect));

ampfallidx = -inf;
difffallidx = -inf;

for tidx = 1:length(ampdetect)
  if ampdetect(tidx) || (tidx <= ampfallidx)
    ampmask(tidx) = NaN;

    if amphalo(tidx)
      ampfallidx = tidx + trimafter;
    end
  end

  if diffdetect(tidx) || (tidx <= difffallidx)
    diffmask(tidx) = NaN;

    if diffhalo(tidx)
      difffallidx = tidx + trimafter;
    end
  end
end

ampfallidx = inf;
difffallidx = inf;

for tidx = length(ampdetect):-1:1
  if ampdetect(tidx) || (tidx >= ampfallidx)
    ampmask(tidx) = NaN;

    if amphalo(tidx)
      ampfallidx = tidx - trimbefore;
    end
  end

  if diffdetect(tidx) || (tidx >= difffallidx)
    diffmask(tidx) = NaN;

    if diffhalo(tidx)
      difffallidx = tidx - trimbefore;
    end
  end
end


%
% Return the masked series.

newseries = oldseries .* ampmask .* diffmask;


%
% Done.

end


%
% This is the end of the file.
