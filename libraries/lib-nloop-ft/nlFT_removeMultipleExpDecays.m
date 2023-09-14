function [ newftdata fitlist ] = ...
  nlFT_removeMultipleExpDecays( oldftdata, fenceposts, method )

% function [ newftdata fitlist ] = ...
%   nlFT_removeMultipleExpDecays( oldftdata, fenceposts, method )
%
% This is a wrapper for nlArt_removeMultipleExpDecays().
%
% This attempts to curve fit and remove settling artifacts composed of
% multiple exponential decay tails.
%
% DC levels are discarded from the curve fits - the "offset" parameters in
% the curve fits are all set to zero.
%
% "oldftdata" is a ft_datatype_raw structure with trial data to process.
% "fenceposts" is a vector containing times to be used as span endpoints for
%   curve fitting. The span between the last two times is curve fit and its
%   contribution subtracted, then the next-last span, and so forth. Only the
%   portion of the wave following the earliest fencepost is modified.
% "method", if present, is a character vector or cell array specifying the
%   algorithms to use to perform exponential fits ('log', 'pinmax', or
%   'pinboth', per "nlArt_fitExpDecay()"). If this is a character vector,
%   the same algorithm is used for all fits. If this is a cell array, it
%   should have one fewer elements than "fenceposts", and specifies the
%   algorithm used for each fit. If "method" is absent, or if any method is
%   specified as '', a default method is chosen.
%
% "newftdata" is a copy of "oldftdata" with the curve fits subtracted.
% "fitlist" is a {ntrials, nchannels, nfits} cell array holding curve fit
%   parameters for successive curve fits (farthest/slowest first). Curve fit
%   parameters are structures as described in ARTFITPARAMS.txt.


% Initialize output.
newftdata = oldftdata;
fitlist = {};


% If we weren't given a method, tell it to use the default.
if ~exist('method', 'var')
  method = '';
end


% Iterate trials and channels, performing curve fitting.

trialcount = length(newftdata.time);
chancount = length(newftdata.label);

for tidx = 1:trialcount
  thistime = newftdata.time{tidx};
  thistrial = newftdata.trial{tidx};

  for cidx = 1:chancount
    thiswave = thistrial(cidx,:);

    [ thiswave thisfitlist ] = nlArt_removeMultipleExpDecays( ...
      thistime, thiswave, fenceposts, method );

    fitcount = length(thisfitlist);
    fitlist(tidx,cidx,1:fitcount) = thisfitlist(:);

    thistrial(cidx,:) = thiswave;
  end

  newftdata.trial{tidx} = thistrial;
end


% Done.
end



%
% This is the end of the file.
