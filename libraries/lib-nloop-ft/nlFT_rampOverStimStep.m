function newftdata = ...
  nlFT_rampOverStimStep( oldftdata, ramp_span, stim_span )

% function newftdata = ...
%   nlFT_rampOverStimStep( oldftdata, ramp_span, stim_span )
%
% This is a wrapper for nlArt_rampOverStimStep().
%
% This NaNs out a stimulation artifact region and applies a ramp over a
% larger portion of each trial to turn the stepwise level shift across the
% stimulation region into a more graceful change (to avoid filter ringing
% in subsequent processing steps).
%
% This is intended to be used after artifact cancellation, so that there
% aren't large excursions in the post-stimulation signal.
%
% "oldftdata" is a ft_datatype_raw structure with trial data to process.
% "ramp_span" [ min max ] is a time range over which to apply the ramp.
% "stim_span" [ min max ] is a time range containing stimulation artifacts
%   to be squashed, or [] to auto-detect existing NaN spans (which may
%   be different lengths for each trial/channel).
%
% "newftdata" is a copy of "oldftdata" with stimulation regions in each trial
%   NaNed out and a gradual ramp between pre-stimulation and
%   post-stimulation DC levels.


% Initialize output.
newftdata = oldftdata;


% Iterate trials and channels, performing squashing and ramping.

trialcount = length(newftdata.time);
chancount = length(newftdata.label);

for tidx = 1:trialcount
  thistime = newftdata.time{tidx};
  thistrial = newftdata.trial{tidx};

  for cidx = 1:chancount
    thiswave = thistrial(cidx,:);

    thiswave = ...
      nlArt_rampOverStimStep( thistime, thiswave, ramp_span, stim_span );

    thistrial(cidx,:) = thiswave;
  end

  newftdata.trial{tidx} = thistrial;
end


% Done.
end



%
% This is the end of the file.
