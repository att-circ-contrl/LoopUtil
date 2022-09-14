function maplist = nlOpenE_parseChannelMapXML_v5( xmlstruct )

% function maplist = nlOpenE_parseChannelMapXML_v5( xmlstruct )
%
% This parses a structure containing a decoded Open Ephys version 0.5.x
% configuration file, and collects any channel mapping information it can
% find.
%
% NOTE - We're listing channel maps in the order that we find them, not
% sorted by stream number.
%
% "xmlstruct" is a structure containing XML configuration data, as read by
%   "readstruct()".
%
% "maplist" is a structure array with one entry per mapping table found in
%   the configuration file. The fields (per "OPENEPHYS_CHANMAP.txt") are:
%   "oldchan" is a vector indexed by new channel number containing the old
%     channel number that maps to each new location, or NaN if none does.
%   "oldref" is a vector indexed by new channel number containing the old
%     channel number to be used as a reference for each new location, or
%     NaN if unspecified.
%   "isenabled" is a vector of boolean values indexed by new channel number
%     indicating which new channels are enabled.


% Initialize.
maplist = struct([]);


% Cheat, and crawl through the tree aggregating all structures that have
% "TypeAttribute" of "ChannelMappingEditor", and return their "CHANNEL"
% structures.
[ rawmaplist rawreflist ] = helper_crawlXML(xmlstruct);


% Sort through the channel mappings we found and add their data.
for midx = 1:length(rawmaplist)

  % This should be a structure array storing NumberAttribute,
  % MappingAttribute, ReferenceAttribute, and EnabledAttribute.
  thisrawmap = rawmaplist{midx};

  % This should be a structure array storing NumberAttribute and
  % ChannelAttribute.
  thisrawref = rawreflist{midx};


  % Copy the relevant data out of these structures.
  % FIXME - Blithely assume that NumberAttribute is not sparse!

  mapidx = [ thisrawmap.NumberAttribute ];
  mapchans = [ thisrawmap.MappingAttribute ];
  maprefbanks = [ thisrawmap.ReferenceAttribute ];
  mapenabled = [ thisrawmap.EnabledAttribute ];

  [ mapidx, sortidx ] = sort(mapidx);
  mapchans = mapchans(sortidx);
  maprefbanks = maprefbanks(sortidx);
  mapenabled = mapenabled(sortidx);

  reflutidx = [ thisrawref.NumberAttribute ];
  reflutchan = [ thisrawref.ChannelAttribute ];

  [ reflutidx, sortidx ] = sort(reflutidx);
  reflutchan = reflutchan(sortidx);


  % Package the resulting mapping and save it.

  % Remember to convert reference bank indices to 1-based.
  thismap = nlOpenE_parseChannelMapGeneric_v5( ...
    mapchans, 1 + maprefbanks, reflutchan, mapenabled );

  if isempty(maplist)
    maplist = thismap;
  else
    maplist(1 + length(maplist)) = thismap;
  end

end


% Done.

end


%
% Helper Functions

function [ maplist reflist ] = helper_crawlXML( thisnode )

  % Initalize.
  maplist = {};
  reflist = {};


  % Figure out if this is a channel mapping node or not.

  isleaf = false;

  if isfield(thisnode, 'TypeAttribute')
    if strcmp(thisnode.TypeAttribute, 'ChannelMappingEditor')
      isleaf = true;
    end
  end


  % If we're a channel mapping node, look for "CHANNEL" and "REFERENCE"
  % and return them.

  if isleaf
    isok = true;

    if isfield(thisnode, 'CHANNEL')
      maplist = { thisnode.CHANNEL };
    elseif isfield(thisnode, 'Channel')
      maplist = { thisnode.Channel };
    elseif isfield(thisnode, 'channel')
      maplist = { thisnode.channel };
    else
      disp('###  ChannelMappingEditor did not contain channel list!');
      isok = false;
    end

    if isfield(thisnode, 'REFERENCE')
      reflist = { thisnode.REFERENCE };
    elseif isfield(thisnode, 'Reference')
      reflist = { thisnode.Reference };
    elseif isfield(thisnode, 'reference')
      reflist = { thisnode.reference };
    else
      disp('###  ChannelMappingEditor did not contain reference list!');
      isok = false;
    end

    % If we didn't find _both_ things we wanted, squash output.
    if ~isok
      maplist = {};
      reflist = {};
    end
  end


  % If we're not a channel mapping node, recurse into any sub-structures.

  if ~isleaf
    flist = fieldnames(thisnode);
    for fidx = 1:length(flist)
      thisfield = flist{fidx};
      thisdata = thisnode.(thisfield);

      if isstruct(thisdata)
        % Remember that struct arrays are a thing.
        for sidx = 1:length(thisdata)
          [ childmaps childrefs ] = helper_crawlXML( thisdata(sidx) );
          maplist = horzcat(maplist, childmaps);
          reflist = horzcat(reflist, childrefs);
        end
      end
    end
  end

end


%
% This is the end of the file.
