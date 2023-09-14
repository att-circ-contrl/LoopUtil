function newftdata = nlFT_subtractCurveFits( oldftdata, timerange, fitlist )

% function newftdata = nlFT_subtractCurveFits( oldftdata, timerange, fitlist )
%
% This reconstructs and removes a series of curve fits from each trial and
% channel in a Field Trip dataset.
%
% "oldftdata" is a ft_datatype_raw structure with trial data to modify.
% "timerange" [ min max ] is a time span over which to reconstruct the
%   curve fits, in seconds.
% "fitlist" is a {ntrials, nchannels} cell array. Each cell array holds a
%   one-dimensional cell array containing curve fit parameters for zero or
%   more curve fits. Curve fit parameters are structures as described in
%   ARTFITPARAMS.txt.
%
% "newftdata" is a copy of "oldftdata" with curve fits subtracted.


newftdata = oldftdata;

trialcount = length(newftdata.time);
chancount = length(newftdata.label);

for tidx = 1:trialcount
  thistime = newftdata.time{tidx};
  thistrial = newftdata.trial{tidx};

  thismask = (thistime >= min(timerange)) & (thistime <= max(timerange));

  if any(thismask)
    for cidx = 1:chancount
      thiswave = thistrial(cidx,:);
      thisfitlist = fitlist{tidx,cidx};

      thisrecon = nlArt_reconFit( thistime(thismask), thisfitlist );
      thiswave(thismask) = thiswave(thismask) - thisrecon;

      thistrial(cidx,:) = thiswave;
    end
  end

  newftdata.trial{tidx} = thistrial;
end


% Done.
end


%
% This is the end of the file.
