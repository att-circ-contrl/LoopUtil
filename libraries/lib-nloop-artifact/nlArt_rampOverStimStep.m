function newwave = ...
  nlArt_rampOverStimStep( timeseries, waveseries, ramp_span, stim_span )

% function newwave = ...
%   nlArt_rampOverStimStep( timeseries, waveseries, ramp_span, stim_span )
%
% This NaNs out a stimulation artifact region and applies a ramp over a
% larger portion of the wave to turn the stepwise level shift across the
% stimulation region into a more graceful change (to avoid filter ringing
% in subsequent processing steps).
%
% This is intended to be used after artifact cancellation, so that there
% aren't large excursions in the post-stimulation signal.
%
% "timeseries" is a vector with sample timestamps.
% "waveseries" is a vector with sample values.
% "ramp_span" [ min max ] is a time range over which to apply the ramp.
% "stim_span" [ min max ] is a time range containing stimulation artifacts
%   to be squashed.
%
% "newwave" is a copy of "waveseries" with the stimulation region NaNed out
%   and a gradual ramp between pre-stimulation and post-stimulation DC
%   levels.


% Initialize output.
newwave = waveseries;


% Fetch limit information for convenience.

rampmin = min(ramp_span);
rampmax = max(ramp_span);

stimmin = min(stim_span);
stimmax = max(stim_span);


% Get spans over which to measure DC levels for ramping.
% These should be as close to the stimulation discontinuity as practical.
% Leave a small amoutn of padding before/after stimulation just in case
% of artifacts. A bit less padding before, a bit more afterwards.

dcspan = (rampmax - rampmin) * 0.1;

premax = stimmin - 0.5 * dcspan;
premin = premax - dcspan;

postmin = stimmax + dcspan;
postmax = postmin + dcspan;


% Get DC levels.

thismask = (timeseries > premin) & (timeseries < premax);
dc_before = mean(waveseries(thismask));

thismask = (timeseries > postmin) & (timeseries < postmax);
dc_after = mean(waveseries(thismask));


% Generate a ramp.
pline = polyfit( [ rampmin rampmax ], [ dc_before dc_after ], 1 );


% For the "before" and "after" segments, subtract the relevant DC levels.
% Since the ramp's endpoints are at these levels, this makes the ramp
% endpoints zero, blending cleanly with the signal.

thismask = (timeseries >= rampmin) & (timeseries <= stimmin);
thisrecon = polyval( pline, timeseries(thismask) );
newwave(thismask) = newwave(thismask) + thisrecon - dc_before;

thismask = (timeseries >= stimmin) & (timeseries <= rampmax);
thisrecon = polyval( pline, timeseries(thismask) );
newwave(thismask) = newwave(thismask) + thisrecon - dc_after;


% Squash the artifact region.

thismask = (timeseries >= stimmin) & (timeseries <= stimmax);
newwave(thismask) = NaN;



% Done.
end



%
% This is the end of the file.
