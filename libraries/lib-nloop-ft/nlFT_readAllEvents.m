function alleventmeta = nlFT_readAllEvents( indir, wantpromote )

% function alleventmeta = nlFT_readAllEvents( indir, wantpromote )
%
% This probes the specified directory using nlIO_readFolderMetadata(), and
% calls nlFT_readEvents() for any channels of type "eventbool" or
% "eventwords" that pass the nlFT_selectChannels() criteria. The results for
% each channel are returned, with metadata.
%
% NOTE - Field Trip channel number is sensitive to filtering. Use
% nlFT_findChannelIndices() to modify ftchanidx if filtering changes.
%
% "indir" is the directory to process.
% "wantpromote" is true if continuous data ("integer", "bool", and
%   "flagvector" types) is to be converted into sparse data, and false if not.
%
% "alleventmeta" is a vector of structures with the following fields:
%   "ftchanlabel" is the Field Trip channel label for this channel.
%   "ftchanidx" is the Field Trip channel number for this channel.
%   "ftchantype" is the Field Trip channel type for this channel.
%   "nlbankid" is the NeuroLoop bank name for this channel.
%   "nlchanid" is the NeuroLoop channel number for this channel.
%   "ftevents" is the Field Trip event list struct array for this channel.


% Initialize output.
% Build cell arrays to make life easier building the structure array, and to
% guarantee that an empty structure array still has the right fields.

resultcount = 0;

allftchanlabel = {};
allftchanidx = {};
allftchantype = {};
allnlbankid = {};
allnlchanid = {};
allftevents = {};


% Read the folder metadata.

foldername = 'datafolder';
[ isok foldermeta ] = nlIO_readFolderMetadata( ...
  struct([]), foldername, indir, 'auto' );


if ~isok
  error(sprintf( ...
    'nlIO_readFolderMetadata() didn''t find anything in "%s".', indir ));
else
  % We only care about this particular folder's metadata.
  bankmeta = foldermeta.folders.(foldername).banks;

  % Iterate through banks and channels, building a channel list.
  % NOTE - Do this in sorted order for consistent numbering.

  iteratebanklist = struct();
  globalchancount = 0;
  chanindexlut = struct();

  banknames = sort( fieldnames(bankmeta) );

  for bidx = 1:length(banknames)
    thisbankname = banknames{bidx};
    thisbankmeta = bankmeta.(thisbankname);
    thistype = thisbankmeta.banktype;

    % Proceed if this is a bank we want to process at all.
    % It has to pass the filter _and_ be a sparse event type or a type that
    % we can convert to a sparse type.

    if nlFT_testWantBank(thisbankname, thistype) ...
      && ( strcmp(thistype, 'eventbool') || strcmp(thistype, 'eventwords') ...
        || strcmp(thistype, 'boolean') || strcmp(thistype, 'flagvector') ...
        || strcmp(thistype, 'integer') )

      % Build and filter the list of prospective channel names.

      thischanlist = thisbankmeta.channels;

      newchanlist = [];
      newchancount = 0;

      for cidx = 1:length(thischanlist)
        thischannum = thischanlist(cidx);
        thischanname = nlFT_makeFTName( thisbankname, thischannum );

        if nlFT_testWantChannel(thischanname)
          % This channel passes our filtering, so it's one we should process.
          newchancount = newchancount + 1;
          newchanlist(newchancount) = thischannum;

          % Update the lookup table of Field Trip channel IDs.
          globalchancount = globalchancount + 1;
          chanindexlut.(thischanname) = globalchancount;
        end
      end

      % If any channels passed filtering, add them to the iteration list.
      if newchancount > 0
        iteratebanklist.(thisbankname) = struct( 'chanlist', newchanlist );
      end

    end
  end

  % Construct the project-level channel list.
  iteratelist = struct( foldername, iteratebanklist );


  % Iterate through the project-level channel list, adding event lists and
  % metadata.

  % FIXME - We're ignoring the result-passing mechanism and are instead
  % modifying the "allXX" cell arrays directly.

  % The Right Way is to have this function return a cell array of metadata
  % structures instead of a vector, which nlIO_iterateChannels would generate
  % directly as its return value, but a vector is easier for the caller to
  % extract individual fields from.

  memchans = nlFT_getMemChans();
  dummyval = nlIO_iterateChannels( foldermeta, iteratelist, memchans, ...
    @nlFT_readAllEvents_helper );
end


% Construct the output structure array.
% This might be empty; that's fine. It'll still have the right fields.

alleventmeta = struct( ...
  'ftchanlabel', allftchanlabel, 'ftchanidx', allftchanidx, ...
  'ftchantype', allftchantype, 'nlbankid', allnlbankid, ...
  'nlchanid', allnlchanid, 'ftevents', allftevents );


%
% Helper Functions

% NOTE - This is nested, rather than local, so that it can access the parent
% function's "allXX" variables.

% FIXME - We're ignoring the result-passing mechanism and are instead
% modifying the "allXX" cell arrays directly.

% This formats metadata and event data for a sparse channel.

function resultval = nlFT_readAllEvents_helper( ...
  metadata, folderid, bankid, chanid, ...
  wavedata, timedata, wavenative, timenative )

  % We know this channel exists.
  % We aren't necessarily reading channels in-order.
  % This might be sparse or might need to be converted.


  % Get Field Trip's name and channel index for this channel.
  thischanname = nlFT_makeFTName(bankid, chanid);
  channelindex = chanindexlut.(thischanname);

  % Get additional metadata that we want.
  thistype = metadata.folders.(folderid).banks.(bankid).banktype;


  % If this is continuous data, make it sparse.
  if ~( strcmp(thistype, 'eventbool') || strcmp(thistype, 'eventwords') )
    % FIXME - Diagnostics.
    disp(sprintf( '.. Converting "%s" (%s) into a sparse event list.', ...
      thischanname, thistype ));

    [ wavenative, timenative ] = ...
      nlUtil_continuousToSparse( wavenative, timenative );
  end


  % Build an event list using the native data.
  % NOTE - Field Trip will promote this to double if it gets processed by
  % ft_read_event().

  % This tolerates empty lists.
  evsampindices = num2cell(timenative);
  evdatavalues = num2cell(wavenative);
  evtypes = cell(size(evsampindices));
  evtypes(:) = { thistype };

  thiseventlist = ...
    struct( 'sample', evsampindices, 'value', evdatavalues, 'type', evtypes );


  % Append this event list and metadata to the output.

  resultcount = resultcount + 1;

  allftchanlabel{resultcount} = thischanname;
  allftchanidx{resultcount} = channelindex;
  allftchantype{resultcount} = thistype;
  allnlbankid{resultcount} = bankid;
  allnlchanid{resultcount} = chanid;
  allftevents{resultcount} = thiseventlist;


  % Return a dummy value.
  resultval = NaN;

end


% Done (parent function).

end


%
% This is the end of the file.
