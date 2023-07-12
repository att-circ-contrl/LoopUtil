function [ newftdata fitlist ] = ...
  nlFT_removeMultipleExpDecays( oldftdata, fenceposts )

% function [ newftdata fitlist ] = ...
%   nlFT_removeMultipleExpDecays( oldftdata, fenceposts )
%
% This is a wrapper for nlArt_removeMultiplExpDecays().
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
%
% "newftdata" is a copy of "oldftdata" with the curve fits subtracted.
% "fitlist" is a {ntrials, nchannels, nfits} cell array holding curve fit
%   parameters for successive curve fits (farthest/slowest first). Curve fit
%   parameters are structures as described in ARTFITPARAMS.txt.


% Initialize output.
newftdata = oldftdata;
fitlist = {};


% Iterate trials and channels, performing curve fitting.

trialcount = length(newftdata.time);
chancount = length(newftdata.label);

for tidx = 1:trialcount
  thistime = newftdata.time{tidx};
  thistrial = newftdata.trial{tidx};

  for cidx = 1:chancount
    thiswave = thistrial(cidx,:);

    [ thiswave thisfitlist ] = nlArt_removeMultipleExpDecays( ...
      thistime, thiswave, fenceposts );

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
