function newftdata = nlFT_removeSlidingWindowPolyfit( ...
  oldftdata, winsecs, polyorder, stridefrac )

% function newftdata = nlFT_removeSlidingWindowPolyfit( ...
%   oldftdata, winsecs, polyorder, stridefrac )
%
% This is a wrapper for nlArt_calcSlidingWindowPolyFit().
%
% This performs a sliding window polynomial fit to remove low-frequency
% components, which are presumed to be artifact excursions.
%
% NOTE - Evaluating the window for every sample will take a while for large
% window sizes and high sampling rates. Decimate using "stride" to speed
% this up.
%
% "oldftdata" is a ft_datatype_raw structure with trial data to process.
% "winsecs" is the sliding window duration in seconds.
% "polyorder" is the polynomial order for curve fitting.
% "stridefrac" is the fraction of the window width by which to slide the
%   window on each step. Use 0 to step by one sample. This should be less
%   than 1/polyorder to capture curve fit details (ideally much less).
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
winsamps = max(1, winsamps);

stridesamps = round(winsamps * stridefrac);
stridesamps = max(1, stridesamps);


% Iterate trials and channels, subtracting curve fits.

for tidx = 1:trialcount
  thistime = newftdata.time{tidx};
  thistrial = newftdata.trial{tidx};

  for cidx = 1:chancount
    thiswave = thistrial(cidx,:);

    thisfit = nlArt_calcSlidingWindowPolyFit( ...
      thiswave, winsamps, polyorder, stridesamps );

    thistrial(cidx,:) = thiswave - thisfit;
  end

  newftdata.trial{tidx} = thistrial;
end


% Done.
end



%
% This is the end of the file.
