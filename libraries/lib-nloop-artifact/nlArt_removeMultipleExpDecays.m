function [ newwave fitlist ] = ...
  nlArt_removeMultipleExpDecays( timeseries, waveseries, fenceposts )

% function [ newwave fitlist ] = ...
%   nlArt_removeMultipleExpDecays( timeseries, waveseries, fenceposts )
%
% This attempts to curve fit and remove a settling artifact composed of
% multiple exponential decay tails.
%
% DC levels are discarded from the curve fits - the "offset" parameters in
% the curve fits are all set to zero.
%
% "timeseries" is a vector with sample timestamps.
% "waveseries" is a vector with sample values to be modified.
% "fenceposts" is a vector containing times to be used as span endpoints for
%   curve fitting. The span between the last two times is curve fit and its
%   contribution subtracted, and then the next-last span, and so forth. Only
%   the portion of the wave following the earliest fencepost is modified.
%
% "newwave" is a copy of "waveseries" with the curve fits subtracted.
% "fitlist" is a cell array holding curve fit parameters for successive
%   curve fits (farthest/slowest first). Curve fit parameters are structures
%   as described in ARTFITPARAMS.txt.


% Initialize output.
newwave = waveseries;
fitlist = {};


% Get fit span start/end points in descending order.
fenceposts = flip(sort(fenceposts));
fencecount = length(fenceposts);
tailmaxlist = fenceposts(1:(fencecount-1));
tailminlist = fenceposts(2:fencecount);


% Get a reconstruction mask for the entire "after stimulation" segment.
aftermask = (timeseries >= min(fenceposts));


% Do the curve fits.

for fidx = 1:length(tailminlist)

  thistailmin = tailminlist(fidx);
  thistailmax = tailmaxlist(fidx);

  thismask = (timeseries > thistailmin) & (timeseries < thistailmax);

  % Automatic DC level extraction is fine.
  % Pin the curve fit to the most extreme sample, so that the tail doesn't
  % dominate the curve fit.
  thisfit = nlArt_fitExpDecay( ...
    timeseries(thismask), newwave(thismask), NaN, 'pinmax' );

  % Subtract this fit from the entire "after first fencepost" segment.
  % NOTE - Squash the "offset" portion before reconstructing.
  thisfit.offset = 0;
  thisrecon = nlArt_reconFit( timeseries(aftermask), thisfit );
  newwave(aftermask) = newwave(aftermask) - thisrecon;

  % Save this set of curve fit parameters.
  fitlist{fidx} = thisfit;

end



% Done.
end



%
% This is the end of the file.
