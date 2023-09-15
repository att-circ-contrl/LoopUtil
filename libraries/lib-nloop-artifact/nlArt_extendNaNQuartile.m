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


%
% First pass: Identify non-NaN spans.

spanstartlist = [];
spanendlist = [];

sampcount = length(oldseries);

if sampcount > 1
  nanmask = isnan(oldseries);
  startmask = nanmask(1:(sampcount-1)) & (~nanmask(2:sampcount));
  endmask = (~nanmask(1:(sampcount-1))) & nanmask(2:sampcount);

  % This was NaN followed by non-NaN; we want the non-NaN location.
  spanstartlist = find(startmask);
  spanstartlist = spanstartlist + 1;

  % This was non-NaN followed by NaN, so it's fine as-is.
  spanendlist = find(endmask);

  if ~isrow(spanstartlist)
    spanstartlist = transpose(spanstartlist);
  end
  if ~isrow(spanendlist)
    spanendlist = transpose(spanendlist);
  end

  % Handle end cases. We don't want to erode ends, so put ends at +/- Inf.
  if ~isnan(oldseries(1))
    spanstartlist = [ -Inf spanstartlist ];
  end
  if ~isnan(oldseries(sampcount))
    spanendlist = [ spanendlist Inf ];
  end

  % The lists should now be the same length and properly aligned.
end


%
% Second pass: Walk through non-NaN spans, eroding them.

for sidx = 1:length(spanstartlist)
  startidx = spanstartlist(sidx);
  endidx = spanendlist(sidx);

  wantstart = isfinite(startidx);
  wantend = isfinite(endidx);

  startidx = max(1, startidx);
  endidx = min(sampcount, endidx);

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
