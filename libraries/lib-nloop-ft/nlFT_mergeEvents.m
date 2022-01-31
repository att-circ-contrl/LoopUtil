function eventsmerged = nlFT_mergeEvents( alleventmeta )

% function eventsmerged = nlFT_mergeEvents( alleventmeta )
%
% This serializes the multiple event lists produced by nlFT_readAllEvents(),
% merging them into a single Field Trip event list.
%
% This discards the event metadata, and replaces the "type" field of each
% event with the Field Trip channel label for the event's source.
%
% "alleventmeta" is a vector of structures containing event channel metadata
%   and Field Trip event lists for each channel, per nlFT_readAllEvents().
%
% "eventsmerged" is a Field Trip event list struct vector containing all
%   events. Stored fields are:
%   "sample" - Event onset time in samples.
%   "value" - Event value (boolean or integer code).
%   "type" - Character array with the event source's channel label.


% Initialize.
% Timestamps are a consistent type; values aren't, so they're a cell array.
mergedtimes = [];
mergedvalues = {};
mergedlabels = {};


% Process each of the supplied event lists.

for cidx = 1:length(alleventmeta)
  % Get this metadata entry.
  thismeta = alleventmeta(cidx);
  thislabel = thismeta.ftchanlabel;

  % Get this list's events.
  thisevlist = thismeta.ftevents;
  thiscount = length(thisevlist);
  thisevtimes = [ thisevlist.sample ];
  thisevvalues = [ thisevlist.value ];

  % Add this list's events to the master list.
  thisevtypes = {};
  thisevtypes(1:thiscount) = { thislabel };
  % Timestamps are a consistent type; values aren't, so they're a cell array.
  mergedtimes = [ mergedtimes thisevtimes ];
  mergedvalues = [ mergedvalues num2cell(thisevvalues) ];
  mergedlabels = [ mergedlabels thisevtypes ];
end


% Build the merged event list.

% Sort everything by timestamp.
% This is why we kept times as a vector instead of a cell array.
[ mergedtimes, sortidx ] = sort(mergedtimes);
mergedtimes = num2cell(mergedtimes);
mergedvalues = mergedvalues(sortidx);
mergedlabels = mergedlabels(sortidx);

% Make the merged struct array.
eventsmerged = struct( 'sample', mergedtimes, 'value', mergedvalues, ...
  'type', mergedlabels );


% Done.

end


%
% This is the end of the file.
