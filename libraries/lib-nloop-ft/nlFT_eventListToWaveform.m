function wavedata = ...
  nlFT_eventListToWaveform( ftevents, desiredlabel, samprange )

% function wavedata = ...
%   nlFT_eventListToWaveform( ftevents, desiredlabel, samprange )
%
% This processes a Field Trip event list and converts it to a waveform.
%
% "ftevents" is a vector of Field Trip event records. Relevant fields are
%   "value", "sample", and "type" (containing the channel label).
% "desiredlabel" is a character vector containing the value to match to the
%   events' "type" field. If this is empty, all events are accepted.
% "samprange" [ min max ] is the span of sample indices to generate data for.
%
% "wavedata" is a waveform spanning the specified range of sample indices,
%   where the value of any given sample is the value of the most
%   recently-seen event, or zero if there were no prior events.


eventindices = [];
eventvalues = [];

if ~isempty(ftevents)
  if ~isempty(fieldnames(ftevents))
    eventindices = [ ftevents(:).sample ];
    eventvalues = [ ftevents(:).value ];
    eventlabels = { ftevents(:).type };

    if ~isempty(desiredlabel)
      evmask = strcmp(eventlabels, desiredlabel);
      eventindices = eventindices(evmask);
      eventvalues = eventvalues(evmask);
    end
  end
end

wavedata = nlUtil_sparseToContinuous( eventindices, eventvalues, samprange );


% Done.
end


%
% This is the end of the file.
