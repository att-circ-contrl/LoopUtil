function folderresults = nlOpenE_iterateFolderChannels( ...
  foldermetadata, folderchanlist, memchans, procfunc, procmeta, procfid )

% function folderresults = nlOpenE_iterateFolderChannels( ...
%   foldermetadata, folderchanlist, memchans, procfunc, procmeta, procfid )
%
% This processes a folder containing Open Ephys format data, iterating
% through a list of channels, loading each channel's waveform data in
% sequence and calling a processing function with that data. Processing
% output is aggregated and returned.
%
% This is implemented such that only a few channels are loaded at a time.
%
% "Native" channel time series are stored as sample numbers (not times).
% "Cooked" channel time series are in seconds. Cooked analog data is
% converted to the units specified in the bank metadata (volts or microvolts).
% Cooked TTL data is converted to boolean.
%
% "foldermetadata" is a folder-level metadata structure, per FOLDERMETA.txt.
% "folderchanlist" is a structure listing channels to process; it is a
%   folder-level channel list per CHANLIST.txt.
% "memchans" is the maximum number of channels that may be loaded into
%   memory at the same time.
% "procfunc" is a function handle used to transform channel waveform data
%   into "result" data, per PROCFUNC.txt.
% "procmeta" is the object to pass as the "metadata" argument of "procfunc".
% "procfid" is the label to pass as the "folderid" argument of "procfunc".
%
% "folderresults" is a folder-level channel list structure that has
%   bank-level channel lists augmented with a "resultlist" field, per
%   CHANLIST.txt. The "resultlist" field is a cell array containing
%   per-channel output from "procfunc".


% Initialize output.
folderresults = struct();


% Iterate through the requested bank list.

banklist = fieldnames(folderchanlist);
for bidx = 1:length(banklist)

  % Make sure we have metadata for this bank before processing it.
  thisbanklabel = banklist{bidx};
  if isfield(foldermetadata.banks, thisbanklabel)

    % Initialize output.

    chanfoundlist = [];
    chanresultlist = {};


    % Look up appropriate metadata.

    thisbankmeta = foldermetadata.banks.(thisbanklabel);
    thisbankchanlist = folderchanlist.(thisbanklabel);
    thisbankchans = thisbankchanlist.chanlist;
    thisbanksamprange = [];
    if isfield(thisbankchanlist, 'samprange')
      thisbanksamprange = thisbankchanlist.samprange;
    end
    firstsamp = 1;
    lastsamp = 1;
    if ~isempty(thisbanksamprange)
      firstsamp = min(thisbanksamprange);
      lastsamp = max(thisbanksamprange);
    end

    thissigtype = thisbankmeta.banktype;
    thissignativetype = thisbankmeta.nativedatatype;
    thiszerolevel = thisbankmeta.nativezerolevel;
    thisscale = thisbankmeta.nativescale;

    thishandle = thisbankmeta.handle;
    thisformat = thishandle.format;
    thiscategory = thishandle.type;


    % How we iterate this depends on how it's stored.

    if strcmp(thisformat, 'monolithic')

      % Check to see what type of data we're dealing with.
      if strcmp('continuous', thiscategory)

        % Memory-map this file.

        % FIXME - We can't explicitly close the memmapfile object.
        % FIXME - Matlab's documentation says the memmapfile object can be
        % cleared to release it, but this doesn't seem to work in my tests.
        % FIXME - Count on it vanishing when "thisdata" is reassigned and
        % when exiting function scope. This is an ugly kludge!

        thisdata = load_open_ephys_binary( thishandle.oefile, ...
          'continuous', thishandle.oebank, 'mmap' );

        % Get raw and cooked timestamps.
        timenative = thisdata.Timestamps;
        timecooked = double(timenative) / thisbankmeta.samprate;

        % Get the handle to memory-mapped data.
        thismmaphandle = thisdata.Data;


        % Get a reverse map of channels to Open Ephys channel indices.
        thischanindices = find(thishandle.selectmask);


        % Get a list of channels that exist and their mapped indices.
        % Silently drop requested channels that don't exist.

        foundcount = 0;
        filteredchans = [];
        filteredmappedindices = [];
        for cidx = 1:length(thisbankchans)
          thischanid = thisbankchans(cidx);
          if ismember(thischanid, thisbankmeta.channels)

            % Find the slice corresponding to this channel.
            thisindex = find( thischanid == thisbankmeta.channels );
            thisindex = thischanindices( min(thisindex) );

            foundcount = foundcount + 1;
            filteredchans(foundcount) = thischanid;
            filteredmappedindices(foundcount) = thisindex;
          end
        end

        % Segment the list into batches.
        filteredchans = helper_segmentList(filteredchans, memchans);
        filteredmappedindices = ...
          helper_segmentList(filteredmappedindices, memchans);


        % Iterate the requested channels, reading and processing the ones
        % that exist.
        % Do this in batches rather than one at a time, to speed up reading.

        foundcount = 0;
        for batchidx = 1:length(filteredchans)

          thisbatchchans = filteredchans{batchidx};
          thisbatchmappedindices = filteredmappedindices{batchidx};

          % Read the native data for this batch of channels.
          if isempty(thisbanksamprange)
            batchdatanative = thismmaphandle.Data.mapped( ...
              thisbatchmappedindices, : );
          else
            % FIXME - We need bounds checking on firstsamp and lastsamp.
            batchdatanative = thismmaphandle.Data.mapped( ...
              thisbatchmappedindices, firstsamp:lastsamp );
          end

          % Walk through the loaded channels, processing them one by one.
          for cidx = 1:length(thisbatchchans)

            % Get the channel ID.
            thischanid = thisbatchchans(cidx);

            % Get the channel's data. This should copy by reference, since
            % we're not modifying it.
            datanative = batchdatanative(cidx,:);

            % Make cooked data.
            datacooked = zeros(size(datanative));
            if strcmp('boolean', thissigtype)
              % Convert to boolean (logical) values.
              datacooked = (datanative > 0.5);
            elseif strcmp('flagvector', thissigtype)
              % Convert to double but don't modify.
              datacooked = double(datanative);
            else
              % Convert to double and apply offset and scaling.
              datacooked = double(datanative);
              datacooked = (datacooked - thisbankmeta.nativezerolevel) ...
                * thisbankmeta.nativescale;
            end

            % Process this channel.
            thisresult = ...
              procfunc( procmeta, procfid, thisbanklabel, thischanid, ...
                datacooked, timecooked, datanative, timenative );

            % Store the result.
            foundcount = foundcount + 1;
            chanfoundlist(foundcount) = thischanid;
            chanresultlist{foundcount} = thisresult;

          end

        end

      elseif strcmp('events', thiscategory)

        % Load the sparse event data.
        % FIXME - Blithely assume that this fits in memory!

        thiseventlist = load_open_ephys_binary( thishandle.oefile, ...
          'events', thishandle.oebank );


        % NOTE - Take different actions depending on whether we have bit data
        % or word data.
        % We're still keeping event lists sparse, but we need to convert to
        % to a sensible format.

        if strcmp('eventbool', thissigtype)

          % Get a list of channels that exist and their mapped indices.
          % Silently drop requested channels that don't exist.
          % Unlike "continuous" banks, "event" banks aren't combined, so we
          % don't have to worry about only a subset of native channels being
          % bank channels.

          foundcount = 0;
          filteredchans = [];
          filteredmappedindices = [];
          for cidx = 1:length(thisbankchans)
            thischanid = thisbankchans(cidx);
            if ismember(thischanid, thisbankmeta.channels)

              % Find the slice corresponding to this channel.
              thisindex = find( thischanid == thisbankmeta.channels );
              thisindex = min(thisindex);

              foundcount = foundcount + 1;
              filteredchans(foundcount) = thischanid;
              filteredmappedindices(foundcount) = thisindex;
            end
          end


          % Iterate the requested channels, reading and processing the ones
          % that exist.

          % NOTE - Since we've already read the event data, there's no reason
          % to batch channels. Just iterate them one at a time.

          foundcount = 0;
          for cidx = 1:length(filteredchans)

            % Get the channel ID.
            thischanid = filteredchans(cidx);
            thisnativechanindex = filteredmappedindices(cidx);

            % Get the events that we care about.
            % NOTE - Even if we have no matching elements, process the data.

            eventmask = (thisnativechanindex == thiseventlist.ChannelIndex);

            timenative = thiseventlist.Timestamps(eventmask);
            timecooked = double(timenative) / thisbankmeta.samprate;

            eventvals = thiseventlist.Data(eventmask);

            % Turn this into a boolean sequence.
            % Rising edges are "+chan", falling are "-chan".
            % This works even if we have an empty list.
            datanative = (eventvals > 0);

            % Cooked boolean is still boolean.
            datacooked = datanative;

            % If we have a sample range, filter for that range.
            if ~isempty(thisbanksamprange)
              eventmask = ...
                (timenative >= firstsamp) & (timenative <= lastsamp);
              timenative = timenative(eventmask);
              timecooked = timecooked(eventmask);
              datanative = datanative(eventmask);
              datacooked = datacooked(eventmask);
            end

            % Process this channel.
            thisresult = ...
              procfunc( procmeta, procfid, thisbanklabel, thischanid, ...
                datacooked, timecooked, datanative, timenative );

            % Store the result.
            foundcount = foundcount + 1;
            chanfoundlist(foundcount) = thischanid;
            chanresultlist{foundcount} = thisresult;

          end

        elseif strcmp('eventwords', thissigtype)

          % FIXME - We only have one channel for word data.
          % This is an alias for merged bitwise data.

          % Sanity check.
          if length(thisbankchans) ~= 1
            % FIXME - Diagnostics.
            disp(sprintf( ...
  '###  Expected one channel of word data for bank "%s"; found %d.', ...
              thisbanklabel, length(thisbankchans) ));
          else
            thischanid = thisbankchans(1);

            foundcount = 0;

            timenative = thiseventlist.Timestamps;
            timecooked = double(timenative) / thisbankmeta.samprate;

            % This tolerates a list with zero events.
            datanative = nlOpenE_assembleWords( ...
              thiseventlist.FullWords, thissignativetype );

            % FIXME - Double may lose bits, if we have more than 50-ish bits.
            datacooked = double(datanative);

            % If we have a sample range, filter for that range.
            if ~isempty(thisbanksamprange)
              eventmask = ...
                (timenative >= firstsamp) & (timenative <= lastsamp);
              timenative = timenative(eventmask);
              timecooked = timecooked(eventmask);
              datanative = datanative(eventmask);
              datacooked = datacooked(eventmask);
            end

            % Process this channel.
            thisresult = ...
              procfunc( procmeta, procfid, thisbanklabel, thischanid, ...
                datacooked, timecooked, datanative, timenative );

            % Store the result.
            foundcount = foundcount + 1;
            chanfoundlist(foundcount) = thischanid;
            chanresultlist{foundcount} = thisresult;
          end

        else
          % FIXME - Text events NYI!

          % FIXME - Diagnostics.
          disp(sprintf( '### Not sure how to iterate "%s" events.', ...
            thissigtype ));
        end

      else
        % FIXME - Spike data NYI!

        % FIXME - Diagnostics.
        disp(sprintf( '### Not sure how to iterate "%s" data.', ...
          thiscategory ));
      end

    else
      % FIXME - Old one-file-per-channel format NYI.

      % FIXME - Diagnostics.
      disp(sprintf( '### Not sure how to iterate a "%s" folder.', ...
        thisformat ));
    end


    % Store this bank's results.
    % Remember to wrap cell arrays.

    folderresults.(thisbanklabel) = ...
      struct( 'chanlist', chanfoundlist, 'resultlist', { chanresultlist } );

  end

end



% Done.

end


%
% Helper functions.

% This function segments a long list into shorter pieces. Order is preserved.
% "origlist" is a vector to be segmented.
% "maxnum" is the maximum number of elements per segment.
% "segmentlist" is a cell array containing shorter vectors.

function segmentlist = helper_segmentList( origlist, maxnum )

  segmentlist = {};

  origlength = length(origlist);
  if origlength > 0

    startlist = 1:maxnum:origlength;

    % Most segments are maxnum long.
    endlist = startlist + maxnum - 1;
    % The last segment might be short.
    endlist(length(endlist)) = origlength;

    for bidx = 1:length(startlist)
      segmentlist{bidx} = origlist( startlist(bidx) : endlist(bidx) );
    end
  end

  % Done.
end


%
% This is the end of the file.
