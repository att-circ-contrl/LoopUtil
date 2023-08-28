function [ newwave fitlist ] = nlArt_removeMultipleExpDecays( ...
  timeseries, waveseries, fenceposts, method )

% function [ newwave fitlist ] = nlArt_removeMultipleExpDecays( ...
%  timeseries, waveseries, fenceposts, method )
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
% "method", if present, is a character vector or cell array specifying the
%   algorithms to use to perform the exponential fits ('log', 'pinmax', or
%   'pinboth', per "nlArt_fitExpDecay()"). If this is a character vector,
%   the same algorithm is used for all fits. If this is a cell array, it
%   should have one fewer elements than "fenceposts", and specifies the
%   algorithm used for each fit. If "method" is absent, or if any method is
%   specified as '', a default method is chosen.
%
% "newwave" is a copy of "waveseries" with the curve fits subtracted.
% "fitlist" is a cell array holding curve fit parameters for successive
%   curve fits (farthest/slowest first). Curve fit parameters are structures
%   as described in ARTFITPARAMS.txt.


% Initialize output.
newwave = waveseries;
fitlist = {};


% Get methods for each segment.

defaultmethod = 'pinmax';
if ~exist('method', 'var')
  method = defaultmethod;
end

methodlist = {};

for fidx = 1:(length(fenceposts) - 1)
  if ischar(method)
    methodlist{fidx} = method;
  elseif fidx <= length(method)
    methodlist{fidx} = method{fidx};
  else
    methodlist{fidx} = defaultmethod;
  end

  if isempty(methodlist{fidx})
    methodlist{fidx} = defaultmethod;
  end
end

% Add an extra entry so that this is the same length as "fenceposts", for
% sorting.

% FIXME - "Correct" behavior is undefined for unsorted lists. So we'll assume
% that if we were given different methods at all, the list was supplied in
% either ascending or descending order. If we were given only one method, or
% no methods, all elements are the same and what we do here doesn't matter.

if length(fenceposts) > 1
  if fenceposts(1) > fenceposts(2)
    % Descending order. Add a new entry at the end.
    methodlist = [ methodlist { defaultmethod } ];
  else
    % Ascending order. Add a new entry at the beginning.
    methodlist = [ { defaultmethod } methodlist ];
  end
end


% Get fit span start/end points in descending order.
% Sort the methods array the same way, and discard the last entry.

[ fenceposts, sortidx ] = sort(fenceposts, 'descend');
methodlist = methodlist(sortidx);

fencecount = length(fenceposts);
tailmaxlist = fenceposts(1:(fencecount-1));
tailminlist = fenceposts(2:fencecount);
methodlist= methodlist(1:(fencecount-1));


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
    timeseries(thismask), newwave(thismask), NaN, methodlist{fidx} );

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
