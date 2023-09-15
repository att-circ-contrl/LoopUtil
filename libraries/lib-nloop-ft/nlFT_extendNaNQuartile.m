function newftdata = nlFT_extendNaNQuartile( oldftdata, threshold )

% function newftdata = nlFT_extendNaNQuartile( oldftdata, threshold )
%
% This segments signals into NaN and non-NaN regions, and extends the NaN
% regions to cover adjacent samples that are sufficiently large excursions
% from their host non-NaN regions.
%
% This is intended to extend artifact-squash regions to cover portions of
% the artifact that are still present after squashing.
%
% This is a wrapper for nlArt_extendNaNQuartile.
%
% "oldftdata" is a ft_datatype_raw dataset to process.
% "threshold" is the amount by which the signal must depart from the median
%   level to be considered a residual artifact. This is a multiple of the
%   median-to-quartile distance (about two thirds of a standard deviation).
%   Typical values are 6-12 for clear exponential excursions. If this is
%   NaN or Inf, no squashing is performed.
%
% "newftdata" is a copy of "oldftdata" with NaN regions extended to cover
%   adjacent excursions.


newftdata = oldftdata;

if isfinite(threshold)

  trialcount = length(newftdata.time);
  chancount = length(newftdata.label);

  for tidx = 1:trialcount
    thistrial = newftdata.trial{tidx};

    for cidx = 1:chancount
      thiswave = thistrial(cidx,:);
      thiswave = nlArt_extendNaNQuartile( thiswave, threshold );
      thistrial(cidx,:) = thiswave;
    end

    newftdata.trial{tidx} = thistrial;
  end

end


% Done.
end


%
% This is the end of the file.
