function newftdata = ...
  nlFT_removeSlidingWindowPolyfit( oldftdata, winsecs, polyorder )

% function newftdata = ...
%   nlFT_removeSlidingWindowPolyfit( oldftdata, winsecs, polyorder )
%
% This is a wrapper for nlArt_calcSlidingWindowPolyFit().
%
% This performs a sliding window polynomial fit to remove low-frequency
% components, which are presumed to be artifact excursions.
%
% NOTE - Because this is evaluated for every sample, it takes a while for
% large window sizes and high sampling rates.
%
% "oldftdata" is a ft_datatype_raw structure with trial data to process.
% "winsecs" is the sliding window duration in seconds.
% "polyorder" is the polynomial order for curve fitting.
%
% "newftdata" is a copy of "oldftdata" with the curve fits subtracted.


% Initialize output.
newftdata = oldftdata;


% Get metadata.

trialcount = length(newftdata.time);
chancount = length(newftdata.label);

samprate = NaN;
if trialcount > 0
  samprate = 1 / median(diff( newftdata.time{1} ));
end

winsamps = round(winsecs * samprate);


% Iterate trials and channels, subtracting curve fits.

for tidx = 1:trialcount
  thistime = newftdata.time{tidx};
  thistrial = newftdata.trial{tidx};

  for cidx = 1:chancount
    thiswave = thistrial(cidx,:);

    thisfit = nlArt_calcSlidingWindowPolyFit( thiswave, winsamps, polyorder );

    thistrial(cidx,:) = thiswave - thisfit;
  end

  newftdata.trial{tidx} = thistrial;
end


% Done.
end



%
% This is the end of the file.
