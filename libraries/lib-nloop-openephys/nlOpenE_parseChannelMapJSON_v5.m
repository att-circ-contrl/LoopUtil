function maplist = nlOpenE_parseChannelMapJSONv5( jsonstruct )

% function maplist = nlOpenE_parseChannelMapJSONv5( jsonstruct )
%
% This parses a structure containing decoded JSON describing the
% configuration of an Open Ephys version 0.5.x channel map node.
%
% NOTE - Open Ephys labels streams in the channel map starting at 0.
% Matlab will index them in the struct array starting at 1.
%
% "jsonstruct" is a structure containing JSON data, from "jsondecode()".
%
% "maplist" is a structure array with one entry per mapping table found in
%   the original structure. The fields (per "OPENEPHYS_CHANMAP.txt") are:
%   "oldchan" is a vector indexed by new channel number containing the old
%     channel number that maps to each new location, or NaN if none does.
%   "oldref" is a vector indexed by new channel number containing the old
%     channel number to be used as a reference for each new location, or
%     NaN if unspecified.
%   "isenabled" is a vector of boolean values indexed by new channel number
%     indicating which new channels are enabled.


% Initialize.
maplist = struct([]);


% The top-level structure should have "recording", "refs", and per-stream
% fields. Per-stream fields were saves as numbers in JSON, but are turned
% into "xN" by Matlab to produce valid field names.

if ~isempty(jsonstruct)

  % Ignore the "recording" field.


  % Get the "refs" data.

  % NOTE - Reference indices 0-based, but we're using a 1-based list.
  reflist = [];
  if isfield(jsonstruct, 'refs')
    reflist = jsonstruct.refs.channels;
  end


  % Walk through the fields looking for per-stream data.

  jfields = fieldnames(jsonstruct);
  for fidx = 1:length(jfields)
    thisfield = jfields{fidx};
    alltokens = regexp(thisfield, '(\d+)$', 'tokens');

    if ~isempty(alltokens)
      thisbankidx = alltokens{1}{1};
      thisbankdata = jsonstruct.(thisfield);

      thisoldchan = thisbankdata.mapping;
      thisoldref = thisbankdata.reference;
      thisenabled = thisbankdata.enabled;

      % Translate the reference table.
      % Remember to convert reference bank indices to 1-based.
      thismap = nlOpenE_parseChannelMapGeneric_v5( ...
        thisoldchan, 1 + thisoldref, reflist, thisenabled );

      % Save this stream's information.
      if isempty(maplist)
        maplist = thismap;
      else
        maplist(1 + length(maplist)) = thismap;
      end
    end
  end

end



% Done.

end


%
% This is the end of the file.
