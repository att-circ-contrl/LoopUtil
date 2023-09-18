function newseries = nlArt_extendNaNQuartile( oldseries, threshold )

% function newseries = nlArt_extendNaNQuartile( oldseries, threshold )
%
% This segments a signal into NaN and non-NaN regions, and extends the NaN
% regions to cover adjacent samples that are sufficiently large excursions
% from their host non-NaN regions.
%
% This is intended to extend artifact-squash regions to cover portions of
% the artifact that are still present after squashing.
%
% "oldseries" is the series to process.
% "threshold" is the amount by which the signal must depart from the median
%   level to be considered a residual artifact. This is a multiple of the
%   median-to-quartile distance (about two thirds of a standard deviation).
%   Typical values are 6-12 for clear exponential excursions. If this is
%   NaN or Inf, no squashing is performed.
%
% "newseries" is a copy of "oldseries" with NaN regions extended to cover
%   adjacent excursions.


newseries = oldseries;


if ~isfinite(threshold)
  return;
end


% Identify non-NaN spans.

[ spanstartlist spanendlist nanstartlist nanendlist ] = ...
  nlProc_findNaNSpans(newseries);


% Walk through non-NaN spans, eroding them.

% NOTE - Special-case the first and last samples of the data series, since
% we don't want to erode those.

sampcount = length(newseries);

for sidx = 1:length(spanstartlist)
  startidx = spanstartlist(sidx);
  endidx = spanendlist(sidx);

  wantstart = (startidx > 1);
  wantend = (endidx < sampcount);

  thisdata = newseries(startidx:endidx);
  [ threshlow threshhigh threshmedian ] = nlProc_getOutlierThresholds( ...
    thisdata, 25, 75, threshold, threshold );

  % Find the earliest and latest _normal_ samples, and keep them.
  normalmask = (thisdata >= threshlow) & (thisdata <= threshhigh);

  newdata = NaN(size(thisdata));
  if any(normalmask)

    normstart = 1;
    if wantstart
      normstart = min(find(normalmask));
    end

    normend = length(thisdata);
    if wantend
      normend = max(find(normalmask));
    end

    newdata(normstart:normend) = thisdata(normstart:normend);

  end

  newseries(startidx:endidx) = newdata;
end


% Done.
end


%
% This is the end of the file.
