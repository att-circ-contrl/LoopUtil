function [ risetimes falltimes bothtimes ] = ...
  nlFT_getEventEdges( ftevents, desiredlabel, samprate )

% function [ risetimes falltimes bothtimes ] = ...
%   nlFT_getEventEdges( ftevents, desiredlabel, samprate )
%
% This processes a Field Trip event list that is assumed to represent boolean
% (TTL) events and identifies the times of rising and falling edges.
%
% "ftevents" is a vector of Field Trip event records. Relevant fields are
%   "value", "sample", and "type" (containing the channel label).
% "desiredlabel" is a character vector containing the value to match to
%   events' "type" field. If this is empty, all events are accepted.
% "samprate" is the sampling rate (used to convert the "sample" field to
%   times in seconds). If this is NaN, the contents of "sample" are returned.
%
% "risetimes" contains timestamps (in seconds) of logical-1 events.
% "falltimes" contains timestamps (in seconds) of logical-0 events.
% "bothtimes" contains timestamps (in seconds) of all matching events.


risetimes = [];
falltimes = [];
bothtimes = [];

if ~isempty(ftevents)
  if ~isempty(fieldnames(ftevents))

    event_labels = { ftevents(:).type };
    event_states = logical([ ftevents(:).value ]);
    event_times = [ ftevents(:).sample ];

    if ~isempty(desiredlabel)
      evmask = strcmp(event_labels, desiredlabel);
      event_states = event_states(evmask);
      event_times = event_times(evmask);
    end

    if ~isnan(samprate)
      event_times = event_times / samprate;
    end

    risetimes = sort( event_times(event_states) );
    falltimes = sort( event_times(~event_states) );
    bothtimes = sort( event_times );

  end
end


% Done.
end


%
% This is the end of the file.
